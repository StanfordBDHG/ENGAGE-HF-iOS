//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SpeziViews
import SwiftUI


struct InterestingModules: View {
    @Environment(ManagedNavigationStack.Path.self) private var managedNavigationStackPath
    
    
    var body: some View {
        SequentialOnboardingView(
            title: "INTERESTING_MODULES_TITLE",
            subtitle: "INTERESTING_MODULES_SUBTITLE",
            steps: [
                SequentialOnboardingView.Step(
                    title: "INTERESTING_MODULES_AREA1_TITLE",
                    description: "INTERESTING_MODULES_AREA1_DESCRIPTION"
                ),
                SequentialOnboardingView.Step(
                    title: "INTERESTING_MODULES_AREA2_TITLE",
                    description: "INTERESTING_MODULES_AREA2_DESCRIPTION"
                ),
                SequentialOnboardingView.Step(
                    title: "INTERESTING_MODULES_AREA3_TITLE",
                    description: "INTERESTING_MODULES_AREA3_DESCRIPTION"
                ),
                SequentialOnboardingView.Step(
                    title: "INTERESTING_MODULES_AREA4_TITLE",
                    description: "INTERESTING_MODULES_AREA4_DESCRIPTION"
                ),
                SequentialOnboardingView.Step(
                    title: "INTERESTING_MODULES_AREA5_TITLE",
                    description: "INTERESTING_MODULES_AREA5_DESCRIPTION"
                )
            ],
            actionText: "INTERESTING_MODULES_BUTTON",
            action: {
                managedNavigationStackPath.nextStep()
            }
        )
    }
}


#if DEBUG
#Preview {
    ManagedNavigationStack {
        InterestingModules()
    }
}
#endif
