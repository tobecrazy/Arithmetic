import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        // 确保CoreData模型在初始化时创建
        setupCoreDataStack()
        
        // 迁移现有数据
        migrateExistingData()
    }
    
    private func setupCoreDataStack() {
        // 初始化CoreData堆栈
        _ = persistentContainer
    }
    
    // 迁移现有数据以适应模型更改
    private func migrateExistingData() {
        // 检查是否有需要迁移的错题
        let fetchRequest: NSFetchRequest<WrongQuestionEntity> = WrongQuestionEntity.fetchRequest()
        
        do {
            let existingQuestions = try context.fetch(fetchRequest)
            
            // 为现有错题添加解析方法和步骤
            for question in existingQuestions {
                // 尝试访问新属性，如果失败则添加默认值
                do {
                    // 尝试访问solutionMethod属性
                    _ = question.solutionMethod
                } catch {
                    // 如果属性不存在，则添加默认值
                    if let questionObj = question.toQuestion() {
                        question.setValue(questionObj.getSolutionMethod().rawValue, forKey: "solutionMethod")
                        question.setValue(questionObj.getSolutionSteps(), forKey: "solutionSteps")
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
            resetCoreDataStore()
        }
    }
    
    // 重置Core Data存储（如果迁移失败）
    private func resetCoreDataStore() {
        print("尝试重置Core Data存储...")
        
        // 获取持久化存储的URL
        guard let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url else {
            print("无法获取持久化存储URL")
            return
        }
        
        do {
            // 删除所有持久化存储
            for store in persistentContainer.persistentStoreCoordinator.persistentStores {
                try persistentContainer.persistentStoreCoordinator.remove(store)
            }
            
            // 删除存储文件
            try FileManager.default.removeItem(at: storeURL)
            
            // 重新加载持久化存储
            try persistentContainer.persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: nil
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
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
