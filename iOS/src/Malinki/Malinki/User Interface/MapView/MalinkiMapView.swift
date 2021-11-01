//
//  MalinkiMapView.swift
//  Malinki
//
//  Created by Christoph Jung on 30.06.21.
//

import SwiftUI
import MapKit
import CoreLocation

struct MalinkiMapView: UIViewRepresentable {
    
    @Binding private var basemapID: Int
    @Binding private var mapThemeID: Int
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    
    init(basemapID: Binding<Int>, mapThemeID: Binding<Int>) {
        self._basemapID = basemapID
        self._mapThemeID = mapThemeID
    }
    
    func makeUIView(context: UIViewRepresentableContext<MalinkiMapView>) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let zoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
        //register the annotations
        //...
        
        //configure the map view
        mapView.showsCompass = true
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsScale = true
//        mapView.showsUserLocation = true
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MalinkiMapView>) {
        self.updateAnnotations(from: view)
        self.updateOverlays(from: view)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateAnnotations(from mapView: MKMapView) {
        //remove all annotations from the map
        mapView.removeAnnotations(mapView.annotations)
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
        
//        if let mapTheme = MalinkiConfigurationProvider.sharedInstance.getMapTheme(for: self.mapThemeID) {
//            //iterate over all raster layers
//            for rasterLayer in mapTheme.layers.rasterLayers.sorted(by: {$0.id < $1.id}) {
//
//                //get the map layer corresponding to the current raster layer
//                guard let mapLayer = self.mapLayers.filter({$0.id == rasterLayer.id}).first else { continue }
//
//                //check the visibility of the current layer
//                if mapLayer.isToggled {
//                    //get a layer according to the data source
//                    let layer = MalinkiRasterData(from: rasterLayer)
//
//                    //add the layer to the map
//                    if layer.isAppleMaps {
//                        mapView.mapType = layer.getAppleMapType()
//                    } else {
//                        let overlay = layer.getOverlay()
//                        overlay.canReplaceMapContent = false
//                        mapView.addOverlay(overlay)
//                    }
//                }
//            }
//        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinates = view.annotation?.coordinate else { return }
        let span = mapView.region.span
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}

//MARK: - Delegate for the Map View
final class Coordinator: NSObject, MKMapViewDelegate {
    var control: MalinkiMapView
    
    init(_ control: MalinkiMapView) {
        self.control = control
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        return nil
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //focus the map on the selected annotation
        guard let coordinates = view.annotation?.coordinate else { return }
        let span = mapView.region.span
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinates.latitude - span.latitudeDelta / 4, longitude: coordinates.longitude), span: span)
        mapView.setRegion(region, animated: true)
    }
    
//    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
//        
//    }
}

struct MalinkiMapView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapView(basemapID: .constant(0), mapThemeID: .constant(0))
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray()))
    }
}
