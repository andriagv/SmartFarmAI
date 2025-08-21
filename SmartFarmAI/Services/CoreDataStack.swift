import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    let container: NSPersistentContainer

    private init() {
        let model = NSManagedObjectModel()

        // PlanEntity
        let plan = NSEntityDescription()
        plan.name = "PlanEntity"
        plan.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        plan.properties = [
            NSAttributeDescription.with(name: "id", type: .UUIDAttributeType),
            NSAttributeDescription.with(name: "crop", type: .stringAttributeType),
            NSAttributeDescription.with(name: "region", type: .stringAttributeType),
            NSAttributeDescription.with(name: "soilQuality", type: .integer16AttributeType),
            NSAttributeDescription.with(name: "farmSizeHa", type: .doubleAttributeType),
            NSAttributeDescription.with(name: "plantingDates", type: .binaryDataAttributeType),
            NSAttributeDescription.with(name: "recommendations", type: .binaryDataAttributeType),
            NSAttributeDescription.with(name: "createdAt", type: .dateAttributeType)
        ]

        // ScanEntity
        let scan = NSEntityDescription()
        scan.name = "ScanEntity"
        scan.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        scan.properties = [
            NSAttributeDescription.with(name: "id", type: .UUIDAttributeType),
            NSAttributeDescription.with(name: "diseaseName", type: .stringAttributeType),
            NSAttributeDescription.with(name: "confidence", type: .doubleAttributeType),
            NSAttributeDescription.with(name: "severity", type: .stringAttributeType),
            NSAttributeDescription.with(name: "recommendation", type: .stringAttributeType),
            NSAttributeDescription.with(name: "date", type: .dateAttributeType)
        ]

        model.entities = [plan, scan]

        container = NSPersistentContainer(name: "SmartFarmAI", managedObjectModel: model)
        container.loadPersistentStores { _, _ in }
    }

    func savePlan(_ plan: FarmPlan) {
        let ctx = container.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "PlanEntity", into: ctx)
        entity.setValue(plan.id, forKey: "id")
        entity.setValue(plan.crop.rawValue, forKey: "crop")
        entity.setValue(plan.region, forKey: "region")
        entity.setValue(plan.soilQuality, forKey: "soilQuality")
        entity.setValue(plan.farmSizeHa, forKey: "farmSizeHa")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let datesData = try? encoder.encode(plan.plantingDates)
        let recsData = try? encoder.encode(plan.recommendations)
        entity.setValue(datesData, forKey: "plantingDates")
        entity.setValue(recsData, forKey: "recommendations")
        entity.setValue(plan.createdAt, forKey: "createdAt")
        try? ctx.save()
    }

    func saveScan(_ scan: PestAnalysisResult) {
        let ctx = container.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "ScanEntity", into: ctx)
        entity.setValue(scan.id, forKey: "id")
        entity.setValue(scan.diseaseName, forKey: "diseaseName")
        entity.setValue(scan.confidence, forKey: "confidence")
        entity.setValue(scan.severity.rawValue, forKey: "severity")
        entity.setValue(scan.recommendation, forKey: "recommendation")
        entity.setValue(scan.date, forKey: "date")
        try? ctx.save()
    }

    func fetchPlans() -> [FarmPlan] {
        let ctx = container.viewContext
        let req = NSFetchRequest<NSManagedObject>(entityName: "PlanEntity")
        let objs = (try? ctx.fetch(req)) ?? []
        return objs.compactMap { o in
            guard
                let id = o.value(forKey: "id") as? UUID,
                let cropRaw = o.value(forKey: "crop") as? String,
                let crop = Crop(rawValue: cropRaw),
                let region = o.value(forKey: "region") as? String,
                let soil = o.value(forKey: "soilQuality") as? Int,
                let size = o.value(forKey: "farmSizeHa") as? Double,
                let datesData = o.value(forKey: "plantingDates") as? Data,
                let recsData = o.value(forKey: "recommendations") as? Data,
                let created = o.value(forKey: "createdAt") as? Date
            else { return nil }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dates = (try? decoder.decode([Date].self, from: datesData)) ?? []
            let recs = (try? decoder.decode([Recommendation].self, from: recsData)) ?? []
            return FarmPlan(id: id, crop: crop, region: region, soilQuality: soil, farmSizeHa: size, plantingDates: dates, recommendations: recs, createdAt: created)
        }
    }

    func fetchScans() -> [PestAnalysisResult] {
        let ctx = container.viewContext
        let req = NSFetchRequest<NSManagedObject>(entityName: "ScanEntity")
        let objs = (try? ctx.fetch(req)) ?? []
        return objs.compactMap { o in
            guard
                let id = o.value(forKey: "id") as? UUID,
                let name = o.value(forKey: "diseaseName") as? String,
                let conf = o.value(forKey: "confidence") as? Double,
                let sevRaw = o.value(forKey: "severity") as? String,
                let sev = PestSeverity(rawValue: sevRaw),
                let rec = o.value(forKey: "recommendation") as? String,
                let date = o.value(forKey: "date") as? Date
            else { return nil }
            return PestAnalysisResult(id: id, diseaseName: name, confidence: conf, severity: sev, recommendation: rec, date: date)
        }
    }
}

private extension NSAttributeDescription {
    static func with(name: String, type: NSAttributeType) -> NSAttributeDescription {
        let a = NSAttributeDescription()
        a.name = name
        a.attributeType = type
        a.isOptional = false
        switch type {
        case .transformableAttributeType:
            a.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue
            a.allowsExternalBinaryDataStorage = true
        case .binaryDataAttributeType:
            a.allowsExternalBinaryDataStorage = true
        default:
            break
        }
        return a
    }
}


