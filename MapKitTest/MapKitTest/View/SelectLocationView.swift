//
//  SelectLocationView.swift
//  MapKitTest
//
//  Created by 전준수 on 3/25/24.
//

import SwiftUI
import MapKit

struct SelectLocationView: View {
    @StateObject var locationViewModel: LocationViewModel = .init()
    // MARK: Navigation Tag to Push View to MapView
    @State var navigationTag: String?
    var body: some View {
        
        VStack {
            HStack(spacing: 15) {
                Text("위치")
                    .font(.title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Find locations here", text: $locationViewModel.searchText)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.gray)
            }
            .padding(.vertical, 10)
            
            if let places = locationViewModel.fetchedPlaces, !places.isEmpty {
                List {
                    ForEach(places, id: \.self){ place in
                        Button {
                            if let coordinate = place.location?.coordinate {
                                locationViewModel.pickedLocation = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                locationViewModel.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                locationViewModel.addDraggablePin(coordinate: coordinate)
                                locationViewModel.updatePlaceMark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                            }
                            
                            // MARK: Navigationg To MapView
                            navigationTag = "MAPVIEW"
                            
                            
                        } label: {
                            HStack(spacing: 15) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(place.subLocality ?? "")
                                        .font(.title3.bold())
                                        .foregroundColor(.primary)
                                    
                                    Text(place.locality ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                    }
                }
                .listStyle(.plain)
            } else {
                List {
                  
                        HStack(spacing: 15) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(locationViewModel.locationSubLocality)")
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                
                                Text("\(locationViewModel.locationLocality)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                  
                    

                    
                    
                    
                }
                .listStyle(.plain)
                .task {
                    self.locationViewModel.reverseGeocodingLocality(latitude: locationViewModel.latitude, longitude: locationViewModel.longitude) {address in
                        self.locationViewModel.locationLocality = address
                    }
                    self.locationViewModel.reverseGeocodingSubLocality(latitude: locationViewModel.latitude, longitude: locationViewModel.longitude) {address in
                        self.locationViewModel.locationSubLocality = address
                    }
                }
                
                
                
                
                
            }
        }
        .padding(.all, 25)
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            NavigationLink(tag: "MAPVIEW", selection: $navigationTag) {
                MapViewSelection()
                    .environmentObject(locationViewModel)
                    .navigationBarHidden(true)
            } label: { }
                .labelsHidden()
        }
    }
}

#Preview {
    SelectLocationView()
}

// MARK: MapView Live Selection
struct MapViewSelection: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack(alignment: .bottom) {
            MapViewHelper()
                .environmentObject(locationViewModel)
                .ignoresSafeArea()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .topLeading)
            
            // MARK: Displaying Data
            if let place = locationViewModel.pickedPlaceMark {
                VStack(spacing: 15) {
                    Text("Confirm Location")
                        .font(.title2.bold())
                    
                    HStack(spacing: 15) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.subLocality ?? "")
                                .font(.title3.bold())
                            
                            Text(place.locality ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    
                    Button {
                        
                    } label: {
                        Text("Confirm Location")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.green)
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: "arrow.right")
                                    .font(.title3.bold())
                                    .padding(.trailing)
                            }
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .ignoresSafeArea()
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
        }
        .onDisappear {
            locationViewModel.pickedLocation = nil
            locationViewModel.pickedPlaceMark = nil
            
            locationViewModel.mapView.removeAnnotations(locationViewModel.mapView.annotations)
        }
    }
}

// MARK: UIkit MapView
struct MapViewHelper: UIViewRepresentable {
    @EnvironmentObject var locationViewModel: LocationViewModel
    func makeUIView(context: Context) -> MKMapView {
        return locationViewModel.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}
