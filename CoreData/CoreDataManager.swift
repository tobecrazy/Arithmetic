import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    private var isInitialized = false
    private var initializationError: Error?

    private init() {
        // 确保CoreData模型在初始化时创建
        setupCoreDataStack()

        // Only migrate if initialization succeeded
        if isInitialized {
            // 迁移现有数据
            migrateExistingData()
        }
    }

    private func setupCoreDataStack() {
        // 初始化CoreData堆栈
        _ = persistentContainer

        // If initialization failed, attempt recovery
        if initializationError != nil, let storeURL = getStoreURL() {
            print("Core Data initialization had error, attempting recovery...")
            resetStore(at: storeURL)
        }
    }

    private func getStoreURL() -> URL? {
        let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url

        // If no store exists yet, compute the default URL
        if storeURL == nil {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return directory?.appendingPathComponent("ArithmeticModel.sqlite")
        }

        return storeURL
    }

    // 迁移现有数据以适应模型更改
    private func migrateExistingData() {
        guard isInitialized else {
            print("Cannot migrate: Core Data not initialized")
            return
        }

        // 检查是否有需要迁移的错题
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()

        do {
            let existingQuestions = try context.fetch(fetchRequest)

            // 为现有错题添加解析方法和步骤
            for question in existingQuestions {
                // Ensure that each question has solutionMethod and solutionSteps
                if question.solutionMethod.isEmpty {
                    if let questionObj = question.toQuestion() {
                        let level = DifficultyLevel(rawValue: question.level) ?? .level1
                        question.setValue(questionObj.getSolutionMethod(for: level).rawValue, forKey: "solutionMethod")
                        question.setValue(questionObj.getSolutionSteps(for: level), forKey: "solutionSteps")
                    } else {
                        question.setValue("standard", forKey: "solutionMethod")
                        question.setValue("", forKey: "solutionSteps")
                    }
                }
            }

            // 保存更改
            if context.hasChanges {
                try context.save()
                print("成功迁移 \(existingQuestions.count) 个错题")
            }
        } catch {
            print("迁移数据时出错: \(error)")

            // 如果迁移失败，尝试重置数据库
            if let storeURL = getStoreURL() {
                resetStore(at: storeURL)
            }
        }
    }

    // 重置Core Data存储（如果迁移失败）
    private func resetStore(at storeURL: URL) {
        print("尝试重置Core Data存储...")

        do {
            // 删除所有持久化存储
            for store in persistentContainer.persistentStoreCoordinator.persistentStores {
                try persistentContainer.persistentStoreCoordinator.remove(store)
            }

            // 删除存储文件 and related files
            try FileManager.default.removeItem(at: storeURL)

            // Remove WAL and SHM files if they exist
            let walURL = storeURL.deletingLastPathComponent().appendingPathComponent(storeURL.lastPathComponent + "-wal")
            let shmURL = storeURL.deletingLastPathComponent().appendingPathComponent(storeURL.lastPathComponent + "-shm")

            try? FileManager.default.removeItem(at: walURL)
            try? FileManager.default.removeItem(at: shmURL)

            // 重新加载持久化存储
            try persistentContainer.persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true
                ]
            )

            print("Core Data存储已重置")
        } catch {
            print("重置Core Data存储失败: \(error)")
        }
    }
    
    // 创建CoreData模型
    private func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // 创建WrongQuestion实体
        let wrongQuestionEntity = NSEntityDescription()
        wrongQuestionEntity.name = "WrongQuestion"
        wrongQuestionEntity.managedObjectClassName = NSStringFromClass(WrongQuestionEntity.self)
        
        // 创建WrongQuestion属性
        var wrongQuestionProperties: [NSPropertyDescription] = []
        
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        wrongQuestionProperties.append(idAttribute)
        
        let questionTextAttribute = NSAttributeDescription()
        questionTextAttribute.name = "questionText"
        questionTextAttribute.attributeType = .stringAttributeType
        questionTextAttribute.isOptional = false
        wrongQuestionProperties.append(questionTextAttribute)
        
        let correctAnswerAttribute = NSAttributeDescription()
        correctAnswerAttribute.name = "correctAnswer"
        correctAnswerAttribute.attributeType = .integer32AttributeType
        correctAnswerAttribute.isOptional = false
        wrongQuestionProperties.append(correctAnswerAttribute)
        
        let levelAttribute = NSAttributeDescription()
        levelAttribute.name = "level"
        levelAttribute.attributeType = .stringAttributeType
        levelAttribute.isOptional = false
        wrongQuestionProperties.append(levelAttribute)
        
        let numbersAttribute = NSAttributeDescription()
        numbersAttribute.name = "numbers"
        numbersAttribute.attributeType = .stringAttributeType
        numbersAttribute.isOptional = false
        wrongQuestionProperties.append(numbersAttribute)
        
        let operationsAttribute = NSAttributeDescription()
        operationsAttribute.name = "operations"
        operationsAttribute.attributeType = .stringAttributeType
        operationsAttribute.isOptional = false
        wrongQuestionProperties.append(operationsAttribute)
        
        let combinationKeyAttribute = NSAttributeDescription()
        combinationKeyAttribute.name = "combinationKey"
        combinationKeyAttribute.attributeType = .stringAttributeType
        combinationKeyAttribute.isOptional = false
        wrongQuestionProperties.append(combinationKeyAttribute)
        
        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false
        wrongQuestionProperties.append(createdAtAttribute)
        
        let lastShownAtAttribute = NSAttributeDescription()
        lastShownAtAttribute.name = "lastShownAt"
        lastShownAtAttribute.attributeType = .dateAttributeType
        lastShownAtAttribute.isOptional = true
        wrongQuestionProperties.append(lastShownAtAttribute)
        
        let timesShownAttribute = NSAttributeDescription()
        timesShownAttribute.name = "timesShown"
        timesShownAttribute.attributeType = .integer16AttributeType
        timesShownAttribute.isOptional = false
        timesShownAttribute.defaultValue = 0
        wrongQuestionProperties.append(timesShownAttribute)
        
        let timesWrongAttribute = NSAttributeDescription()
        timesWrongAttribute.name = "timesWrong"
        timesWrongAttribute.attributeType = .integer16AttributeType
        timesWrongAttribute.isOptional = false
        timesWrongAttribute.defaultValue = 0
        wrongQuestionProperties.append(timesWrongAttribute)
        
        // 添加解析方法属性
        let solutionMethodAttribute = NSAttributeDescription()
        solutionMethodAttribute.name = "solutionMethod"
        solutionMethodAttribute.attributeType = .stringAttributeType
        solutionMethodAttribute.isOptional = true
        solutionMethodAttribute.defaultValue = "standard"
        wrongQuestionProperties.append(solutionMethodAttribute)
        
        // 添加解析步骤属性
        let solutionStepsAttribute = NSAttributeDescription()
        solutionStepsAttribute.name = "solutionSteps"
        solutionStepsAttribute.attributeType = .stringAttributeType
        solutionStepsAttribute.isOptional = true
        solutionStepsAttribute.defaultValue = ""
        wrongQuestionProperties.append(solutionStepsAttribute)
        
        wrongQuestionEntity.properties = wrongQuestionProperties
        
        // 创建GameProgress实体
        let gameProgressEntity = NSEntityDescription()
        gameProgressEntity.name = "GameProgress"
        gameProgressEntity.managedObjectClassName = NSStringFromClass(GameProgressEntity.self)
        
        // 创建GameProgress属性
        var gameProgressProperties: [NSPropertyDescription] = []
        
        let progressIdAttribute = NSAttributeDescription()
        progressIdAttribute.name = "id"
        progressIdAttribute.attributeType = .UUIDAttributeType
        progressIdAttribute.isOptional = false
        gameProgressProperties.append(progressIdAttribute)
        
        let difficultyLevelAttribute = NSAttributeDescription()
        difficultyLevelAttribute.name = "difficultyLevel"
        difficultyLevelAttribute.attributeType = .stringAttributeType
        difficultyLevelAttribute.isOptional = false
        gameProgressProperties.append(difficultyLevelAttribute)
        
        let currentQuestionIndexAttribute = NSAttributeDescription()
        currentQuestionIndexAttribute.name = "currentQuestionIndex"
        currentQuestionIndexAttribute.attributeType = .integer16AttributeType
        currentQuestionIndexAttribute.isOptional = false
        gameProgressProperties.append(currentQuestionIndexAttribute)
        
        let scoreAttribute = NSAttributeDescription()
        scoreAttribute.name = "score"
        scoreAttribute.attributeType = .integer16AttributeType
        scoreAttribute.isOptional = false
        gameProgressProperties.append(scoreAttribute)
        
        let timeRemainingAttribute = NSAttributeDescription()
        timeRemainingAttribute.name = "timeRemaining"
        timeRemainingAttribute.attributeType = .integer16AttributeType
        timeRemainingAttribute.isOptional = false
        gameProgressProperties.append(timeRemainingAttribute)
        
        let questionsAttribute = NSAttributeDescription()
        questionsAttribute.name = "questions"
        questionsAttribute.attributeType = .binaryDataAttributeType
        questionsAttribute.isOptional = false
        gameProgressProperties.append(questionsAttribute)
        
        let userAnswersAttribute = NSAttributeDescription()
        userAnswersAttribute.name = "userAnswers"
        userAnswersAttribute.attributeType = .binaryDataAttributeType
        userAnswersAttribute.isOptional = false
        gameProgressProperties.append(userAnswersAttribute)
        
        let savedAtAttribute = NSAttributeDescription()
        savedAtAttribute.name = "savedAt"
        savedAtAttribute.attributeType = .dateAttributeType
        savedAtAttribute.isOptional = false
        gameProgressProperties.append(savedAtAttribute)
        
        let isPausedAttribute = NSAttributeDescription()
        isPausedAttribute.name = "isPaused"
        isPausedAttribute.attributeType = .booleanAttributeType
        isPausedAttribute.isOptional = false
        isPausedAttribute.defaultValue = false
        gameProgressProperties.append(isPausedAttribute)
        
        let pauseUsedAttribute = NSAttributeDescription()
        pauseUsedAttribute.name = "pauseUsed"
        pauseUsedAttribute.attributeType = .booleanAttributeType
        pauseUsedAttribute.isOptional = false
        pauseUsedAttribute.defaultValue = false
        gameProgressProperties.append(pauseUsedAttribute)
        
        gameProgressEntity.properties = gameProgressProperties
        
        // 添加实体到模型
        model.entities = [wrongQuestionEntity, gameProgressEntity]
        
        return model
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        // 创建内存中的模型
        let model = createManagedObjectModel()

        // 创建持久化容器
        let container = NSPersistentContainer(name: "ArithmeticModel", managedObjectModel: model)

        // Configure persistent store descriptions with migration options
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSSQLiteStoreType
        storeDescription.shouldInferMappingModelAutomatically = true
        storeDescription.shouldMigrateStoreAutomatically = true

        container.persistentStoreDescriptions = [storeDescription]

        // Load persistent stores with proper error handling
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Core Data store loading failed: \(error), \(error.userInfo)")
                // Don't use fatalError - instead set the error for later handling
                self.initializationError = error
                self.isInitialized = false
            } else {
                self.isInitialized = true
                print("Core Data store loaded successfully at: \(storeDescription.url?.absoluteString ?? "unknown")")
            }
        }

        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        guard isInitialized else {
            print("Cannot save: Core Data not initialized")
            return
        }

        if context.hasChanges {
            do {
                try context.save()
                print("Context saved successfully")
            } catch {
                let nserror = error as NSError
                print("Failed to save context: \(nserror), \(nserror.userInfo)")

                // Attempt recovery by resetting the store
                if let storeURL = getStoreURL() {
                    resetStore(at: storeURL)
                }
            }
        }
    }
}
