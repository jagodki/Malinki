//
//  MalinkiMapView.swift
//  Malinki
//
//  Created by Christoph Jung on 30.06.21.
//

import SwiftUI
import MapKit
import CoreLocation

@available(iOS 15.0.0, *)
struct MalinkiMapView: UIViewRepresentable {
    
    @Binding private var basemapID: Int
    @Binding private var mapThemeID: Int
    @Binding private var sheetState: MalinkiSheetState?
    @EnvironmentObject var features: MalinkiFeatureDataContainer
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    private var vectorAnnotations: MalinkiVectorAnnotation
    
    init(basemapID: Binding<Int>, mapThemeID: Binding<Int>, sheetState: Binding<MalinkiSheetState?>, vectorAnnotations: MalinkiVectorAnnotation) {
        self._basemapID = basemapID
        self._mapThemeID = mapThemeID
        self._sheetState = sheetState
        self.vectorAnnotations = vectorAnnotations
    }
    
    func showDetailSheet() {
        self.sheetState = .details
    }
    
    func closeSheet() {
        if self.sheetState != .none {
            self.sheetState = .none
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<MalinkiMapView>) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let zoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
        //register the annotations
        mapView.register(MalinkiAnnotationView.self, forAnnotationViewWithReuseIdentifier: "annotations")
        
        //configure the map view
        mapView.showsCompass = true
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsScale = true
//        mapView.showsUserLocation = true
        
        self.setCurrentAnnotations()
        self.setCurrentRasterLayers(for: mapView.region)
        
        return mapView
    }
    
    /// This function edits a dictionary containing information about the current layers represented by annotations.
    private func setCurrentAnnotations() {
        self.vectorAnnotations.currentAnnotations = ["mapTheme": String(self.mapThemeID),
                                                     "areAnnotationsToggled": String(self.areAnnotationsToggled()),
                                                     "layers": self.getVisibleVectorLayers().map({String($0.id)}).joined(separator: "-")]
    }
    
    private func setCurrentRasterLayers(for region: MKCoordinateRegion) {
        self.mapLayers.currentRasterLayers = ["mapTheme": String(self.mapThemeID),
                                              "baseMap": String(self.basemapID),
                                              "layers": self.getVisibleRasterLayerIDs().map({String($0)}).joined(separator: "-")]
        self.mapLayers.currentMapRegion = region
    }
    
    private func areAnnotationsToggled() -> Bool {
        return self.mapLayers.mapThemes.filter({$0.annotationsAreToggled && $0.themeID == self.mapThemeID}).count != 0
    }
    
    private func shouldUpdateRasterOverlays(for region: MKCoordinateRegion) -> Bool {
        let checkMapTheme = self.mapLayers.currentRasterLayers["mapTheme"] != String(self.mapThemeID)
        let checkBaseMap = self.mapLayers.currentRasterLayers["baseMap"] != String(self.basemapID)
        let checkLayers = self.mapLayers.currentRasterLayers["layers"] != self.getVisibleRasterLayerIDs().map({String($0)}).joined(separator: "-")
        let precision = 10000000.0
        let checkLat = round(Double(self.mapLayers.currentMapRegion?.center.latitude ?? 0) * precision) != round(Double(region.center.latitude) * precision)
        let checkLon = round(Double(self.mapLayers.currentMapRegion?.center.longitude ?? 0) * precision) != round(Double(region.center.longitude) * precision)
        let checkLatDelta = round(Double(self.mapLayers.currentMapRegion?.span.latitudeDelta ?? 0) * precision) != round(Double(region.span.latitudeDelta) * precision)
        let checkLonDelta = round(Double(self.mapLayers.currentMapRegion?.span.longitudeDelta ?? 0) * precision) != round(Double(region.span.longitudeDelta) * precision)
        
        return checkMapTheme || checkBaseMap || checkLayers || checkLat || checkLon || checkLatDelta || checkLonDelta
    }
    
    private func shouldUpdateAnnotations() -> Bool {
        let checkMapTheme = self.vectorAnnotations.currentAnnotations["mapTheme"] != String(self.mapThemeID)
        let checkIsThemeToggled = self.vectorAnnotations.currentAnnotations["areAnnotationsToggled"] != String(self.areAnnotationsToggled())
        let checkLayers = self.vectorAnnotations.currentAnnotations["layers"] != self.getVisibleVectorLayers().map({String($0.id)}).joined(separator: "-")
        
        return checkMapTheme || checkIsThemeToggled || checkLayers
    }
    
    /// Get all visible raster layers.
    /// - Returns: <#description#>
    private func getVisibleRasterLayerIDs() -> [Int] {
        return self.mapLayers.rasterLayers.filter({$0.isToggled && $0.themeID == self.mapThemeID}).map({$0.id})
    }
    
    /// Get all vector/annotation layers corresponding to the map theme.
    /// - Returns: <#description#>
    private func getVectorLayers() -> [MalinkiConfigurationVectorData] {
        return MalinkiConfigurationProvider.sharedInstance.getAllVectorLayers(for: self.mapThemeID)
    }
    
    /// Get all visible vector/annotation layers (getVectorLayers() - getVisibleRasterLayerIDs()).
    /// - Returns: <#description#>
    private func getVisibleVectorLayers() -> [MalinkiConfigurationVectorData] {
        return self.getVectorLayers().filter({self.getVisibleRasterLayerIDs().contains($0.correspondingRasterLayer)})
    }
    
    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MalinkiMapView>) {
        if self.vectorAnnotations.deselectAnnotations{
            view.selectedAnnotations.filter({!($0 is MKClusterAnnotation)}).map({view.deselectAnnotation($0, animated: true)})
            self.vectorAnnotations.deselectAnnotations = false
        } else {
            
            self.updateOverlays(from: view)
        }
        
        self.updateAnnotations(from: view)
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateAnnotations(from mapView: MKMapView) {
        //first to check, whether annotations have to be updated or redraw does not affect the annotations
        if self.shouldUpdateAnnotations() {
            
            //remove all not selected annotations from the map
            mapView.removeAnnotations(mapView.annotations)
            
            //add annotations, if theme is toggled
            if self.areAnnotationsToggled() {
                let vectorAnnotations = MalinkiVectorAnnotation()
                mapView.addAnnotations(self.getVisibleVectorLayers().map({vectorAnnotations.getAnnotationFeatures(for: $0.id, in: self.mapThemeID)}).flatMap({$0}))
            }
            self.setCurrentAnnotations()
        }
        
    }
    
    private func updateOverlays(from mapView: MKMapView) {
        
        if self.shouldUpdateRasterOverlays(for: mapView.region) && self.mapLayers.allowRedraw  {
            //remove all overlays from the map
            mapView.removeOverlays(mapView.overlays)
            
            //get the basemap
            if let basemap = MalinkiConfigurationProvider.sharedInstance.getBasemap(for: self.basemapID) {
                
                //create a layer from the given basemap
                let baseLayer = MalinkiRasterData(from: basemap)
                
                //add the basemap to the mapview
                if baseLayer.isAppleMaps {
                    mapView.mapType = baseLayer.getAppleMapType()
                } else {
                    let overlay = baseLayer.getOverlay()
                    overlay.canReplaceMapContent = true
                    mapView.addOverlay(overlay)
                }
            }
            
            //add raster layers from the map theme
            for rasterLayer in self.mapLayers.rasterLayers.filter({$0.themeID == self.mapThemeID}).sorted(by: {$0.id < $1.id}) {
                //che(ck the visibility of the current layer
                if rasterLayer.isToggled {
                    //get a layer according to the data source
                    let layer = MalinkiRasterData(from: MalinkiConfigurationProvider.sharedInstance.getRasterLayer(with: rasterLayer.id, of: rasterLayer.themeID)!)
                    
                    //add the layer to the map
                    if layer.isAppleMaps {
                        mapView.mapType = layer.getAppleMapType()
                    } else {
                        let overlay = layer.getOverlay()
                        overlay.canReplaceMapContent = false
                        mapView.addOverlay(overlay)
                    }
                }
                
                self.setCurrentRasterLayers(for: mapView.region)
            }
        } else {
            //allow the redraw
            self.mapLayers.allowRedraw = true
            
            //remove only polygons and polylines from the mapview
            let polygonsOrLinestrings = mapView.overlays.filter({$0 is MKPolygon || $0 is MKPolyline || $0 is MKMultiPolyline || $0 is MKMultiPolygon})
            mapView.removeOverlays(polygonsOrLinestrings)
        }
        
        //add the geometry of the selected annotation
        if self.features.geometries.count != 0 {
            
            //get the different geometry types
            let polygons = self.features.geometries.filter({$0.type == .polygon})
            let multipolygons = self.features.geometries.filter({$0.type == .multipolygon})
            let linestrings = self.features.geometries.filter({$0.type == .linestring})
            let multilinestring = self.features.geometries.filter({$0.type == .multilinestring})
            
            //create and add one multipolygon
            var allPolygons: [MKPolygon] = []
            allPolygons.append(contentsOf: polygons.map({$0.polygon}))
            allPolygons.append(contentsOf: multipolygons.map({$0.multiPolygon.polygons}).flatMap({$0}))
            mapView.addOverlay(MKMultiPolygon(allPolygons))
            
            //create and add one multilinestring
            var allLinestrings: [MKPolyline] = []
            allLinestrings.append(contentsOf: linestrings.map({$0.linestring}))
            allLinestrings.append(contentsOf: multilinestring.map({$0.multiLinestring.polylines}).flatMap({$0}))
            mapView.addOverlay(MKMultiPolyline(allLinestrings))
        }
    }
    
}

//MARK: - Delegate for the Map View
@available(iOS 15.0.0, *)
final class Coordinator: NSObject, MKMapViewDelegate {
    var control: MalinkiMapView
//    var features: MalinkiFeatureDataContainer
    
    init(_ control: MalinkiMapView) {
        self.control = control
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView? = nil
        
        //check for user location
        if annotation is MKUserLocation {
            annotationView = nil
        }
        
        //create a view for annotations of MalinkiAnnotation
        if annotation is MalinkiAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotations", for: annotation)
        }
        
        if let cluster = annotation as? MKClusterAnnotation {
            let marker = MKMarkerAnnotationView()
            marker.glyphText = String(cluster.memberAnnotations.count)
            marker.markerTintColor = UIColor(Color.accentColor)
            marker.canShowCallout = false
            annotationView = marker
        }
        
        return annotationView
    }
    
    @MainActor func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.control.closeSheet()
        self.control.features.clearAll()
    }
    
    @MainActor func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let overlayRender: MKOverlayRenderer
        
        if overlay is MalinkiTileOverlay {
            let mto = overlay as! MalinkiTileOverlay
            overlayRender = MKTileOverlayRenderer(tileOverlay: mto)
            overlayRender.alpha = mto.alpha
        } else if overlay is MKMultiPolyline {
            let renderer = MKMultiPolylineRenderer(multiPolyline: overlay as! MKMultiPolyline)
            let vectorStyle = MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: self.control.features.selectedAnnotation?.layerID ?? 0, theme: self.control.features.selectedAnnotation?.themeID ?? 0)?.style
            renderer.strokeColor = UIColor(named: vectorStyle?.featureStyle.outline.colour ?? "AccentColor")
            renderer.lineWidth = vectorStyle?.featureStyle.outline.width ?? 1.0
            overlayRender = renderer
            
        } else if overlay is MKMultiPolygon {
            let renderer = MKMultiPolygonRenderer(multiPolygon: overlay as! MKMultiPolygon)
            let vectorStyle = MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: self.control.features.selectedAnnotation?.layerID ?? 0, theme: self.control.features.selectedAnnotation?.themeID ?? 0)?.style
            renderer.strokeColor = UIColor(named: vectorStyle?.featureStyle.outline.colour ?? "AccentColor")
            renderer.fillColor = UIColor(named: vectorStyle?.featureStyle.fill.colour ?? "AccentColor")?.withAlphaComponent(vectorStyle?.featureStyle.fill.opacity ?? 0.5)
            renderer.lineWidth = vectorStyle?.featureStyle.outline.width ?? 1.0
            overlayRender = renderer
        } else {
            overlayRender = MKOverlayRenderer()
        }
        
        return overlayRender
    }
    
    @MainActor func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //get feature data
        if let annotation = view.annotation as? MalinkiAnnotation {
            //focus the map on the selected annotation
            let span = mapView.region.span
            let coordinates = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude - span.latitudeDelta / 4, longitude: annotation.coordinate.longitude)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            mapView.setRegion(region, animated: true)
            
            
            self.control.features.selectedAnnotation = annotation
            self.control.features.span = mapView.region.span
            self.control.features.getFeatureData()
            self.control.showDetailSheet()
        } else {
            self.control.closeSheet()
        }
        
    }
    
}

@available(iOS 15.0.0, *)
struct MalinkiMapView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapView(basemapID: .constant(0), mapThemeID: .constant(0), sheetState: .constant(nil), vectorAnnotations: MalinkiVectorAnnotation())
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray().map({MalinkiTheme(themeID: $0.themeID)})))
            .environmentObject(MalinkiFeatureDataContainer())
    }
}
