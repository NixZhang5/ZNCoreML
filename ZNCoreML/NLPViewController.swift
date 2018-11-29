//
//  NLPViewController.swift
//  ZNCoreML
//
//  Created by xinpin on 2018/11/29.
//  Copyright © 2018年 Nix. All rights reserved.
//

import UIKit

class NLPViewController: UIViewController {

    var tagger = NSLinguisticTagger(tagSchemes: [.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
    var options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let quote = "Here's to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently. They're not fond of rules. And they have no respect for the status quo. You can quote them, disagree with them, glorify or vilify them. About the only thing you can't do is ignore them. Because they change things. They push the human race forward. And while some may see them as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do. -Steve Jobs (Founder of Apple Inc.)"
        
        /*
         1. Language Identification 语言类型
         
         The first step for most NLP algorithms is determining what language the user is talking/typing in.
         */
        print("**************1. Language Identification*****************")
        determineLanguage(for: quote)
        
        /*
         2.Tokenization 词语切分
         
         Tokenization is the process of splitting sentences, paragraphs, or an entire document in to your choice of length. In this scenario, we'll be splitting the quote above into words.
         */
        print("**************2. Tokenization*****************")
        tokenizeText(for: quote)

        /*
         3. Lemmatization   词形还原
         
         Words can be conjugated in many forms. Take the word run for example. It can be running, ran, will run, etc. Since their are many forms of a word, Lemmatization breaks down the word into it's most basic form.
         */
        print("**************3. Lemmatization*****************")
        lemmatization(for: quote)

        /*
         4. Parts of Speech  词类
         
         The function below simply determines the part of speech for each word, whether it's a noun, verb, adjective, etc.
         */
        print("**************4. Parts of Speech*****************")
        partsOfSpeech(for: quote)

        /*
         5. Named Entity Recognition  命名实体识别
         
         Finally, the function scans the quote for any notable names. Knowing any recognizable places can really give the machine context to understand the quote.
         
         命名实体识别（NER）其目的是识别语料中人名、地名、组织机构名等命名实体，识别文本中具有特定意义的实体。它是自然语言处理实用化的重要内容，在信息提取、句法分析、机器翻译等应用领域中具有重要的基础性作用。命名实体识别一 方面要识别实体边界，另一方面要识别实体类别（人名、地名、机构名或其他）。就汉语系统来讲，确定实体边界主要和分词相关，发现命名实体的基本方法，一般 首先找一些与定义相关的特征词，例如：什么是XX，XX是什么，这是XX。找到具有这样模式的查询串后，即可以在查询日志中通过频率统计等方法，找到命名 实体。这里重点讨论第二方面的内容，即类别识别。
        */
        print("**************5. Named Entity Recognition*****************")
        namedEntityRecognition(for: quote)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func determineLanguage(for text: String) {
        tagger.string = text
        let language = tagger.dominantLanguage
        print("The language is \(language!)")
    }
    
    func tokenizeText(for text:String) {
        let range = NSRange(location: 0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { tag, tokenRange, stop in
            let word = (text as NSString).substring(with: tokenRange)
            print(word)
        }
    }
    
    func lemmatization(for text: String) {
        tagger.string = text
        let range = NSRange(location:0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange, stop in
            if let lemma = tag?.rawValue {
                print(lemma)
            }
        }
    }
    
    func partsOfSpeech(for text: String) {
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, _ in
            if let tag = tag {
                let word = (text as NSString).substring(with: tokenRange)
                print("\(word): \(tag.rawValue)")
            }
        }
    }
    
    func namedEntityRecognition(for text: String) {
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                let name = (text as NSString).substring(with: tokenRange)
                print("\(name): \(tag.rawValue)")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
