//
//  MalinkiMapView.swift
//  Malinki
//
//  Created by Christoph Jung on 30.06.21.
//

import SwiftUI
import MapKit

struct MalinkiMapView: UIViewRepresentable {
    
    @Binding var basemapID: Int
    
    init(basemapID: Binding<Int>) {
        self._basemapID = basemapID
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
        mapView.showsUserLocation = true
        
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
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinates = view.annotation?.coordinate else { return }
        let span = mapView.region.span
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}

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
        
        if overlay is MKTileOverlay {
            overlayRender = MKTileOverlayRenderer(tileOverlay: overlay as! MKTileOverlay)
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
        MalinkiMapView(basemapID: .constant(1))
    }
}
