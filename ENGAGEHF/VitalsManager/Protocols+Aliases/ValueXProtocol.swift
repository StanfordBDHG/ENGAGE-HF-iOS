//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4


enum ValueX: Hashable {
    case boolean(FHIRPrimitive<FHIRBool>)
    case codeableConcept(CodeableConcept)
    case dateTime(FHIRPrimitive<DateTime>)
    case integer(FHIRPrimitive<FHIRInteger>)
    case period(Period)
    case quantity(Quantity)
    case range(Range)
    case ratio(Ratio)
    case sampledData(SampledData)
    case string(FHIRPrimitive<FHIRString>)
    case time(FHIRPrimitive<FHIRTime>)
}


protocol ValueXProtocol {
    var type: ValueX { get }
}


extension Observation.ValueX: ValueXProtocol {
    var type: ValueX {
        switch self {
        case .boolean(let boolean): ValueX.boolean(boolean)
        case .codeableConcept(let codeableConcept): ValueX.codeableConcept(codeableConcept)
        case .dateTime(let dateTime): ValueX.dateTime(dateTime)
        case .integer(let integer): ValueX.integer(integer)
        case .period(let period): ValueX.period(period)
        case .quantity(let quantity): ValueX.quantity(quantity)
        case .range(let range): ValueX.range(range)
        case .ratio(let ratio): ValueX.ratio(ratio)
        case .sampledData(let sampledData): ValueX.sampledData(sampledData)
        case .string(let string): ValueX.string(string)
        case .time(let time): ValueX.time(time)
        }
    }
}


extension ObservationComponent.ValueX: ValueXProtocol {
    var type: ValueX {
        switch self {
        case .boolean(let boolean): ValueX.boolean(boolean)
        case .codeableConcept(let codeableConcept): ValueX.codeableConcept(codeableConcept)
        case .dateTime(let dateTime): ValueX.dateTime(dateTime)
        case .integer(let integer): ValueX.integer(integer)
        case .period(let period): ValueX.period(period)
        case .quantity(let quantity): ValueX.quantity(quantity)
        case .range(let range): ValueX.range(range)
        case .ratio(let ratio): ValueX.ratio(ratio)
        case .sampledData(let sampledData): ValueX.sampledData(sampledData)
        case .string(let string): ValueX.string(string)
        case .time(let time): ValueX.time(time)
        }
    }
}
