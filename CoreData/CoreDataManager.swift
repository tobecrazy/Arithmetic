import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        // 确保CoreData模型在初始化时创建
        setupCoreDataStack()
    }
    
    private func setupCoreDataStack() {
        // 初始化CoreData堆栈
        _ = persistentContainer
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
