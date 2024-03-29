//
//  ViewController.swift
//  SwitchAssignment
//
//  Created by Thinh Vo on 2.10.2019.
//  Copyright © 2019 Thinh Vo. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    var userSettingsViewModel: UserSettingsViewModel!

    @IBOutlet weak var mySwitch: UISwitch!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        userSettingsViewModel = UserSettingsViewModel(
            localUserSettingsRepository: LocalUserSettingRepository(),
            remoteUserSettingsReopsitory: RemoteUserSettingRepository(),
            switchUpdate: mySwitch.rx
                .isOn
                .asObservable()
                .skip(1) // Skip the first event (current state of Switch)
                .debounce(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
        )

        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .map { _ -> Void in
                return ()
            }
            .bind(to: userSettingsViewModel.reload)
            .disposed(by: disposeBag)

        setUpBindings()
    }

    private func setUpBindings() {
        userSettingsViewModel.userSettings.drive(onNext: { result in
            switch result {
            case .success(let userSettings):
                self.mySwitch.isOn = userSettings.state
            case .failure(let error):
                print(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }

}
