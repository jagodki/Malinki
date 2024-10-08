//
//  AlertControlView.swift
//  Malinki
//
//  Created by Christoph Jung on 28.05.22.
//

import Foundation
import SwiftUI

enum AlertActionType {
    case insertBookmark
    case updateBookmark
    case insertMapPin
    case updateMapPin
}

@available(iOS 15, *)

/// A structure to show an alert with the possiblity to insert some text in a field.
struct AlertControlView: UIViewControllerRepresentable {
    
    @EnvironmentObject var bookmarksContainer: MalinkiBookmarksProvider
    @EnvironmentObject var userAnnotationsContainer: MalinkiUserAnnotationsProvider
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    @EnvironmentObject var mapRegion: MalinkiMapRegion
    
    @Binding var basemapID: Int
    @Binding var showAlert: Bool
    
    var textString: String = ""
    var title: String
    var message: String
    var actionType: AlertActionType
    var uuidString: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertControlView>) -> UIViewController {
        return UIViewController() // Container on which UIAlertContoller presents
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AlertControlView>) {
        // Make sure that Alert instance exist after View's body get re-rendered
        guard context.coordinator.alert == nil else { return }
        
        if self.showAlert {
            
            // Create UIAlertController instance that is gonna present on UIViewController
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            context.coordinator.alert = alert
            
            // Adds UITextField & make sure that coordinator is delegate to UITextField.
            alert.addTextField { textField in
                textField.placeholder = String(localized: "Enter some text")
                textField.text = ""                         // setting initial value
                textField.delegate = context.coordinator    // using coordinator as delegate
            }
            
            // As usual adding actions
            alert.addAction(UIAlertAction(title: String(localized: "Cancel") , style: .destructive) { _ in
                
                // On dismiss, SiwftUI view's two-way binding variable must be update (setting false) means, remove Alert's View from UI
                alert.dismiss(animated: true) {
                    self.showAlert = false
                }
            })
            
            alert.addAction(UIAlertAction(title: String(localized: "Submit"), style: .default) { _ in
                // On submit action, get texts from TextField & set it on SwiftUI View's two-way binding varaible `textString` so that View receives enter response.
                if let textField = alert.textFields?.first, let text = textField.text {
                    
                    switch self.actionType {
                    case .insertBookmark:
                        withAnimation() {
                            self.bookmarksContainer.bookmarks.append(MalinkiBookmarksObject(
                                id: UUID().uuidString,
                                name: text,
                                theme_id: self.mapLayers.selectedMapThemeID,
                                layer_ids: self.mapLayers.rasterLayers.filter({$0.themeID == self.mapLayers.selectedMapThemeID && $0.isToggled}).map({$0.id}),
                                show_annotations: self.mapLayers.areAnnotationsToggled(),
                                map: MalinkiBookmarksMap(centre: MalinkiBookmarksMapCentre(
                                    latitude: self.mapRegion.mapRegion.center.latitude,
                                    longitude: self.mapRegion.mapRegion.center.longitude), span: MalinkiBookmarksMapSpan(
                                        delta_latitude: self.mapRegion.mapRegion.span.latitudeDelta,
                                        delta_longitude: self.mapRegion.mapRegion.span.longitudeDelta)),
                                basemapID: self.basemapID
                            ))
                        }
                    case .updateBookmark:
                        if let index = self.bookmarksContainer.bookmarks.firstIndex(where: {$0.id == self.uuidString}) {
                            self.bookmarksContainer.bookmarks[index].name = text
                        }
                    case .insertMapPin:
                        self.userAnnotationsContainer.userAnnotations.append(MalinkiUserAnnotation(
                            id: UUID().uuidString,
                            name: text,
                            theme_ids: [self.mapLayers.selectedMapThemeID],
                            position: MalinkiUserAnnotationsPosition(
                                longitude: self.mapRegion.mapRegion.center.longitude,
                                latitude: MalinkiCoordinatesConverter.sharedInstance.latitudeOverSheet(for: self.mapRegion.mapRegion.center.latitude, with: self.mapRegion.mapRegion.span.latitudeDelta))
                        ))
                    case .updateMapPin:
                        if let index = self.userAnnotationsContainer.userAnnotations.firstIndex(where: {$0.id == self.uuidString}) {
                            self.userAnnotationsContainer.userAnnotations[index].name = text
                        }
                    }
                }
                
                alert.dismiss(animated: true) {
                    self.showAlert = false
                }
            })
            
            // Most important, must be dispatched on Main thread
            DispatchQueue.main.async { // must be async !!
                uiViewController.present(alert, animated: true, completion: {
                    self.showAlert = false  // hide holder after alert dismiss
                    context.coordinator.alert = nil
                })
                
            }
        }
    }
    
    func makeCoordinator() -> AlertControlView.Coordinator {
        Coordinator(self)
    }
    
    //MARK: - Coordinator
    class Coordinator: NSObject, UITextFieldDelegate {
        
        // Holds reference of UIAlertController, so that when `body` of view gets re-rendered so that Alert should not disappear
        var alert: UIAlertController?
        
        // Holds back reference to SwiftUI's View
        var control: AlertControlView
        
        init(_ control: AlertControlView) {
            self.control = control
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text as NSString? {
                self.control.textString = text.replacingCharacters(in: range, with: string)
            } else {
                self.control.textString = ""
            }
            return true
        }
    }
    
}


