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
    @Binding private var sheetState: MalinkiSheetState?
    
    @EnvironmentObject var features: MalinkiFeatureDataContainer
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    @EnvironmentObject var mapAnnotations: MalinkiAnnotationContainer
    @EnvironmentObject var mapRegion: MalinkiMapRegion
    @EnvironmentObject var userAnnotationsContainer: MalinkiUserAnnotationsProvider
    
    private var config: MalinkiConfigurationProvider = MalinkiConfigurationProvider.sharedInstance
    
    init(basemapID: Binding<Int>, sheetState: Binding<MalinkiSheetState?>) {
        self._basemapID = basemapID
        self._sheetState = sheetState
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
        mapView.region = self.mapRegion.mapRegion
        
        //add zoom constraints
        let zoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: self.config.getMapConstraints().scale.min, maxCenterCoordinateDistance: self.config.getMapConstraints().scale.max)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
        //add constraints to the visible region
        if let regionConstraints = self.config.getMapConstraints().region {
            let cameraBounds = MKMapView.CameraBoundary(coordinateRegion: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: regionConstraints.center.latitude, longitude: regionConstraints.center.longitude), latitudinalMeters: regionConstraints.latitudinalMeters, longitudinalMeters: regionConstraints.longitudinalMeters))
            mapView.setCameraBoundary(cameraBounds, animated: true)
        }
        
        
        //register the annotations
        mapView.register(MalinkiAnnotationView.self, forAnnotationViewWithReuseIdentifier: "annotations")
        
        //configure the map view
        mapView.showsCompass = true
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsScale = true
//        mapView.showsUserLocation = true
        
        self.mapLayers.queryCurrentAnnotations()
        
        return mapView
    }
    
    private func shouldUpdateRasterOverlays(for region: MKCoordinateRegion) -> Bool {
        let checkMapTheme = self.mapLayers.previousRasterLayers["mapTheme"] != String(self.mapLayers.selectedMapThemeID)
        let checkBaseMap = self.mapLayers.previousRasterLayers["baseMap"] != String(self.basemapID)
        
        let checkLayers = self.mapLayers.previousRasterLayers["layers"] != self.mapLayers.getInformationAboutCurrentRasterlayers(baseMapID: self.basemapID)["layers"]
        
        let precision = 10000000.0
        
        let checkLat = round(Double(self.mapLayers.previousMapRegion?.center.latitude ?? 0) * precision) != round(Double(region.center.latitude) * precision)
        let checkLon = round(Double(self.mapLayers.previousMapRegion?.center.longitude ?? 0) * precision) != round(Double(region.center.longitude) * precision)
        let checkLatDelta = round(Double(self.mapLayers.previousMapRegion?.span.latitudeDelta ?? 0) * precision) != round(Double(region.span.latitudeDelta) * precision)
        let checkLonDelta = round(Double(self.mapLayers.previousMapRegion?.span.longitudeDelta ?? 0) * precision) != round(Double(region.span.longitudeDelta) * precision)
        
        return checkMapTheme || checkBaseMap || checkLayers || checkLat || checkLon || checkLatDelta || checkLonDelta
    }
    
    private func shouldUpdateAnnotations() -> Bool {
        let checkMapTheme = self.mapLayers.previousAnnotations["mapTheme"] != String(self.mapLayers.selectedMapThemeID)
        let checkIsThemeToggled = self.mapLayers.previousAnnotations["areAnnotationsToggled"] != self.mapLayers.getInformationAboutCurrentAnnotations()["areAnnotationsToggled"]
        let checkLayers = self.mapLayers.previousAnnotations["layers"] != self.mapLayers.getInformationAboutCurrentAnnotations()["layers"]
        
        let checkUserAnnotationsIDs = self.userAnnotationsContainer.previousUserAnnotations["ids"] != self.userAnnotationsContainer.getInformationAboutCurrentUserAnnotations()["ids"]
        let checkUserAnnotationsThemes = self.userAnnotationsContainer.previousUserAnnotations["themes"] != self.userAnnotationsContainer.getInformationAboutCurrentUserAnnotations()["themes"]
        let checkUserAnnotationsPositions = self.userAnnotationsContainer.previousUserAnnotations["positions"] != self.userAnnotationsContainer.getInformationAboutCurrentUserAnnotations()["positions"]
        let checkUserAnnotationsNames = self.userAnnotationsContainer.previousUserAnnotations["names"] != self.userAnnotationsContainer.getInformationAboutCurrentUserAnnotations()["names"]
        
        
        return checkMapTheme || checkIsThemeToggled || checkLayers || self.mapAnnotations.newAnnotationsLoaded || checkUserAnnotationsIDs || checkUserAnnotationsThemes || checkUserAnnotationsPositions || checkUserAnnotationsNames
    }
    
    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MalinkiMapView>) {
        //compare the map current map extent with the environment object
        let unequalLongitude = self.mapRegion.mapRegion.center.longitude != view.region.center.longitude
        let unequalLatitude = self.mapRegion.mapRegion.center.latitude != view.region.center.latitude
        let unequalLongitudeDelta = self.mapRegion.mapRegion.span.longitudeDelta != view.region.span.longitudeDelta
        let unequalLatitudeDelta = self.mapRegion.mapRegion.span.latitudeDelta != view.region.span.latitudeDelta
        
        if unequalLatitude || unequalLongitude || unequalLatitudeDelta || unequalLongitudeDelta {
            view.setRegion(self.mapRegion.mapRegion, animated: true)
        }
        
        if self.mapAnnotations.deselectAnnotations{
            _ = view.selectedAnnotations.filter({!($0 is MKClusterAnnotation)}).map({view.deselectAnnotation($0, animated: true)})
            self.mapAnnotations.deselectAnnotations = false
        } else {
            
            self.updateOverlays(from: view)
        }
        
        self.updateAnnotations(from: view)
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateAnnotations(from mapView: MKMapView) {
        //select a user annotation if an ID is given
        if let annotation = mapView.annotations.map({$0 as? MalinkiAnnotation}).filter({$0?.isUserAnnotation ?? false && $0?.featureID == self.userAnnotationsContainer.selectedAnnotationID && $0?.themeID == self.mapLayers.selectedMapThemeID}).first {
            mapView.selectAnnotation(annotation!, animated: true)
        }
        
        //first to check, whether annotations have to be updated or redraw does not affect the annotations
        if self.shouldUpdateAnnotations() {
            
            //remove all not selected annotations from the map
            mapView.removeAnnotations(mapView.annotations)
            
            //add annotations, if theme is toggled
            if self.mapLayers.areAnnotationsToggled() {
                mapView.addAnnotations(self.mapAnnotations.annotations.values.flatMap({$0}))//add user annotations to the map
                mapView.addAnnotations(self.userAnnotationsContainer.getAnnotations().filter({$0.themeID == self.mapLayers.selectedMapThemeID}))
            }
            
            self.mapLayers.setInformationAboutCurrentAnnotations()
            self.userAnnotationsContainer.setInformationAboutCurrentUserAnnotations()
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
                    mapView.preferredConfiguration = baseLayer.getAppleMapConfiguration()
                } else {
                    let overlay = baseLayer.getOverlay()
                    overlay.canReplaceMapContent = true
                    mapView.addOverlay(overlay, level: .aboveLabels)
                }
            }
            
            //add raster layers from the map theme
            for rasterLayer in self.mapLayers.rasterLayers.filter({$0.themeID == self.mapLayers.selectedMapThemeID}).sorted(by: {$0.id < $1.id}) {
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
                        mapView.addOverlay(overlay, level: .aboveLabels)
                    }
                }
                
                self.mapLayers.setInformationAboutCurrentRasterlayers(for: mapView.region, baseMapID: self.basemapID)
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
        self.control.mapRegion.mapRegion = mapView.region
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
        self.control.userAnnotationsContainer.selectedAnnotationID = nil
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
            renderer.strokeColor = UIColor(named: vectorStyle?.featureStyle?.outline.colour ?? "AccentColor")
            renderer.lineWidth = vectorStyle?.featureStyle?.outline.width ?? 1.0
            overlayRender = renderer
            
        } else if overlay is MKMultiPolygon {
            let renderer = MKMultiPolygonRenderer(multiPolygon: overlay as! MKMultiPolygon)
            let vectorStyle = MalinkiConfigurationProvider.sharedInstance.getVectorLayer(id: self.control.features.selectedAnnotation?.layerID ?? 0, theme: self.control.features.selectedAnnotation?.themeID ?? 0)?.style
            renderer.strokeColor = UIColor(named: vectorStyle?.featureStyle?.outline.colour ?? "AccentColor")
            renderer.fillColor = UIColor(named: vectorStyle?.featureStyle?.fill?.colour ?? "AccentColor")?.withAlphaComponent(vectorStyle?.featureStyle?.fill?.opacity ?? 0.5)
            renderer.lineWidth = vectorStyle?.featureStyle?.outline.width ?? 1.0
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
            let coordinates = CLLocationCoordinate2D(latitude: MalinkiCoordinatesConverter.sharedInstance.latitudeUnderSheet(for: annotation.coordinate.latitude, with: span.latitudeDelta), longitude: annotation.coordinate.longitude)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            mapView.setRegion(region, animated: true)
            
            self.control.features.selectedAnnotation = annotation
            self.control.features.span = mapView.region.span
            self.control.features.getFeatureData(for: self.control.mapLayers.rasterLayers.filter({$0.isToggled && $0.themeID == self.control.mapLayers.selectedMapThemeID}).map({$0.id}))
            self.control.showDetailSheet()
        } else {
            self.control.closeSheet()
        }
        
    }
    
}

@available(iOS 15.0.0, *)
struct MalinkiMapView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapView(basemapID: .constant(0), sheetState: .constant(nil))
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray().map({MalinkiTheme(themeID: $0.themeID)}), selectedMapThemeID: 0))
            .environmentObject(MalinkiFeatureDataContainer())
            .environmentObject(MalinkiAnnotationContainer())
            .environmentObject(MalinkiMapRegion(mapRegion: MKCoordinateRegion()))
    }
}
