//
// Copyright © 2021 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI
import Foundation
import UIKit
#if canImport(Virtualization)
import Virtualization
#endif

class UserDefaultsManager {
    private let defaults = UserDefaults.standard
    
    var userServer: String? {
        get {
            return defaults.string(forKey: "userServer")
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: "userServer")
            } else {
                defaults.removeObject(forKey: "userServer")
            }
        }
    }

    var userUDID: String? {
        get {
            return defaults.string(forKey: "userUDID")
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: "userUDID")
            } else {
                defaults.removeObject(forKey: "userUDID")
            }
        }
    }
}

struct VMWizardStartView: View {
    @ObservedObject var wizardState: VMWizardState

    let userDefaultsManager = UserDefaultsManager()

    var isVirtualizationSupported: Bool {
        #if os(macOS)
        VZVirtualMachine.isSupported && !processIsTranslated()
        #else
        UTMCapabilities.current.contains(.hasHypervisorSupport)
        #endif
    }

    var isEmulationSupported: Bool {
        #if !WITH_JIT
        true
        #else
        Main.jitAvailable
        #endif
    }

    var body: some View {
        VMWizardContent("Start") {
            Section {
                let virtButton = Button {
                    wizardState.useVirtualization = true
                    wizardState.next()
                } label: {
                    HStack {
                        Image(systemName: "hare").font(.title)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Virtualize").font(.title)
                            Text("Faster, but can only run the native CPU architecture.").font(.caption)
                        }
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(.inList)
                .disabled(!isVirtualizationSupported)
                #if os(iOS) || os(visionOS)
                if #available(iOS 15, *) {
                    virtButton
                } else {
                    virtButton.opacity(isVirtualizationSupported ? 1 : 0.5)
                }
                #else
                virtButton
                #endif

                Button {
                    wizardState.useVirtualization = false
                    wizardState.next()
                } label: {
                    HStack {
                        Image(systemName: "tortoise").font(.title)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Emulate").font(.title)
                            Text("Slower, but can run other CPU architectures.").font(.caption)
                        }
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(.inList)

            } header: {
                Text("Custom")
            } footer: {
                if !isEmulationSupported && !isVirtualizationSupported {
                    Text("Your version of iOS does not support running VMs while unmodified. You must either run UTM while jailbroken or with a remote debugger attached. See https://getutm.app/install/ for more details.")
                } else if !isVirtualizationSupported {
                    Text("Virtualization is not supported on your system.")
                } else if !isEmulationSupported {
                    Text("This build does not emulation.")
                }
            }

            Section {
                Button {
                    NotificationCenter.default.post(name: NSNotification.OpenVirtualMachine, object: nil)
                } label: {
                    Label {
                        Text("Open…")
                    } icon: {
                        Image(systemName: "doc")
                    }
                }
                #if os(macOS)
                .buttonStyle(.link)
                #endif

                Link(destination: URL(string: "https://mac.getutm.app/gallery/")!) {
                    Label {
                        Text("Download prebuilt from UTM Gallery…")
                    } icon: {
                        Image(systemName: "arrow.down.doc")
                    }
                }
            } header: {
                Text("Existing")
            }

            Section {
                if Main.jitAvailable {
                    Label("JIT-acceleration is enabled", systemImage: "checkmark.circle")
                } else {
                    Label("JIT-acceleration is disabled", systemImage: "xmark.circle")
                }
                Button {
                    resetSideJITDetailsAndQuit()
                } label: {
                    Label {
                        Text("Reset SideJITServer details...")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                }
            } header: {
                Text("UntetherUTM")
            }
        }
    }
        
    private func resetSideJITDetailsAndQuit() {
            userDefaultsManager.userServer = nil
            userDefaultsManager.userUDID = nil

            poopTheThing()
        }

    private func poopTheThing() {
        if let window = UIApplication.shared.windows.first {
            window.isHidden = true
            window.rootViewController = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }

    private func processIsTranslated() -> Bool {
        let key = "sysctl.proc_translated"
        var ret = Int32(0)
        var size: Int = 0
        sysctlbyname(key, nil, &size, nil, 0)
        let result = sysctlbyname(key, &ret, &size, nil, 0)
        if result == -1 {
            return false
        }
        return ret != 0
    }
}

struct VMWizardStartView_Previews: PreviewProvider {
    @StateObject static var wizardState = VMWizardState()
    
    static var previews: some View {
        VMWizardStartView(wizardState: wizardState)
    }
}
