//
//  LocationInfoViewController.swift
//  FindCVS
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import CoreLocation
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class LocationInfoViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    let locationManager = CLLocationManager()
    let mapView = MTMapView()
    let currentLocattionButton = UIButton()
    let detailList = UITableView()
    let viewModel = LocationInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        configure()
        setLayout()
        bind(viewModel: viewModel)
    }
}

private extension LocationInfoViewController {
    func configure() {
        title = "내 주변 편의점 찾기"
        view.backgroundColor = .systemBackground
        mapView.currentLocationTrackingMode = .onWithHeadingWithoutMapMoving
        currentLocattionButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLocattionButton.backgroundColor = .white
        currentLocattionButton.layer.cornerRadius = 20
    }
    
    func setLayout() {
        [mapView, currentLocattionButton, detailList]
            .forEach { view.addSubview($0) }
        
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.snp.centerY).offset(100)
        }
        
        currentLocattionButton.snp.makeConstraints {
            $0.bottom.equalTo(detailList.snp.top).offset(-12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(40)
        }
        
        detailList.snp.makeConstraints {
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.top.equalTo(mapView.snp.bottom)
        }
    }
    
    func bind(viewModel: LocationInfoViewModel) {
        viewModel.setMapCenter
            .emit(to: mapView.rx.setMapCenterPoint)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .emit(to: self.rx.presentAlert)
            .disposed(by: disposeBag)
        
        currentLocattionButton.rx.tap
            .bind(to: viewModel.didTappedCurrentLocationBtn)
            .disposed(by: disposeBag)
    }
}

extension LocationInfoViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, 
                .authorizedWhenInUse, .notDetermined:
            return
        default:
            viewModel.mapViewError.accept(MTMapViewError.locationAuthDenied.errorDescription)
            return
        }
    }
}

extension LocationInfoViewController: MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        #if DEBUG
        viewModel.currentLocation.accept(
            MTMapPoint(
                geoCoord: MTMapPointGeo(
                    latitude: 37.394225,
                    longitude: 127.110341)
            )
        )
        #else
        viewModel.currentLocation.accept(location)
        #endif
    }
    
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        viewModel.mapCenterPoint.accept(mapCenterPoint)
    }
    
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        viewModel.selectPOIItem.accept(poiItem)
        return false
    }
    
    func mapView(_ mapView: MTMapView!, failedUpdatingCurrentLocationWithError error: Error!) {
        viewModel.mapViewError.accept(error.localizedDescription)
    }
}

extension Reactive where Base: MTMapView {
    var setMapCenterPoint: Binder<MTMapPoint> {
        return Binder(base) { base, point in
            base.setMapCenter(point, animated: true)
        }
    }
}

extension Reactive where Base: LocationInfoViewController {
    var presentAlert: Binder<String> {
        return Binder(base) { base, message in
            let alertController = UIAlertController(
                title: "문제 발생",
                message: message,
                preferredStyle: .alert)
            let action = UIAlertAction(
                title: "확인",
                style: .default)
            alertController.addAction(action)
            base.present(alertController, animated: true)
        }
    }
}
