//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct HeartHealthCaption: View {
    var vitalsType: GraphSelection
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Description")
                .studyApplicationHeaderStyle()
            StudyApplicationListCard {
                Text(LocalizedStringKey(vitalsType.explanation))
            }
        }
    }
    

    init(describing vitalsType: GraphSelection) {
        self.vitalsType = vitalsType
    }
}


#Preview {
    HeartHealthCaption(describing: .weight)
}
