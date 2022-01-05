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
        
        return mapView
    }
    
    /// This function edits a dictionary containing information about the current layers represented by annotations.
    private func setCurrentAnnotations() {
        self.vectorAnnotations.currentAnnotations = ["mapTheme": String(self.mapThemeID),
                                                     "isThemeToggled": String(self.isThemeToggled()),
                                                     "layers": self.getVisibleVectorLayers().map({String($0.id)}).joined(separator: "-")]
    }
    
    private func isThemeToggled() -> Bool {
        return self.mapLayers.mapThemes.filter({$0.annotationsAreToggled && $0.themeID == self.mapThemeID}).count != 0
    }
    
    private func shouldUpdateAnnotations() -> Bool {
        let checkMapTheme = self.vectorAnnotations.currentAnnotations["mapTheme"] != String(self.mapThemeID)
        let checkIsThemeToggled = self.vectorAnnotations.currentAnnotations["isThemeToggled"] != String(self.isThemeToggled())
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
        self.updateAnnotations(from: view)
        self.updateOverlays(from: view)
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
            if self.isThemeToggled() {
                let vectorAnnotations = MalinkiVectorAnnotation()
                mapView.addAnnotations(self.getVisibleVectorLayers().map({vectorAnnotations.getAnnotationFeatures(for: $0.id, in: self.mapThemeID)}).flatMap({$0}))
            }
            
            self.setCurrentAnnotations()
            
        }
        
    }
    
    private func updateOverlays(from mapView: MKMapView) {
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let overlayRender: MKOverlayRenderer
        
        if overlay is MalinkiTileOverlay {
            let mto = overlay as! MalinkiTileOverlay
            overlayRender = MKTileOverlayRenderer(tileOverlay: mto)
            overlayRender.alpha = mto.alpha
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
            
            
            self.control.features.annotation = annotation
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
