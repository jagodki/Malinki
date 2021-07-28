//
//  MalinkiMapView.swift
//  Malinki
//
//  Created by Christoph Jung on 30.06.21.
//

import SwiftUI
import MapKit

struct MalinkiMapView: UIViewRepresentable {
    
    private var scaleXPosition: Int
    private var compassXPosition: Int
    private var scaleCompassYPosition: Int
    
    init(scaleXPosition: Int, compassXPosition: Int, scaleCompassYPosition: Int) {
        self.scaleXPosition = scaleXPosition
        self.compassXPosition = compassXPosition
        self.scaleCompassYPosition = scaleCompassYPosition
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
        mapView.mapType = .mutedStandard
        
//        let scale = MKScaleView(mapView: mapView)
//        scale.frame.origin = CGPoint(x: self.scaleXPosition, y: self.scaleCompassYPosition)
//        scale.scaleVisibility = .adaptive
//        mapView.addSubview(scale)
//        
//        //reposition the compass
//        let compassButton = MKCompassButton(mapView:mapView)
//        compassButton.frame.origin = CGPoint(x: self.compassXPosition, y: self.scaleCompassYPosition)
//        compassButton.compassVisibility = .adaptive
//        mapView.addSubview(compassButton)
        
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
        
        if overlay is MKMultiPolyline {
            let renderer = MKMultiPolylineRenderer(multiPolyline: overlay as! MKMultiPolyline)
            switch overlay.title {
            case "river":
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 2
            default:
                renderer.strokeColor = UIColor.green
                renderer.lineWidth = 2
            }
            
            return renderer
            
        } else if overlay is MKMultiPolygon {
            let renderer = MKMultiPolygonRenderer(multiPolygon: overlay as! MKMultiPolygon)
            switch overlay.title {
            case "countries":
                renderer.strokeColor = UIColor.red
                renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
                renderer.lineWidth = 2
            default:
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 2
            }
            return renderer
        }
        
        return MKOverlayRenderer()
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
        MalinkiMapView(scaleXPosition: 80, compassXPosition: 15, scaleCompassYPosition: 20)
    }
}
