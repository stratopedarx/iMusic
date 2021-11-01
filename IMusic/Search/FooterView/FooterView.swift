//
//  FooterView.swift
//  IMusic
//
//  Created by Sergey Lobanov on 01.11.2021.
//

import UIKit

class FooterView: UIView {
    // с помощью кложура можем настроить конфигурацию
    private var myLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        // если мы хотим настроить с помощью кода, с помощью констрэйнтов, то ставим false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 161, green: 165, blue: 169, alpha: 1)
        return label
    }()
    
    private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        // что бы пропадал, когда останавливается
        loader.hidesWhenStopped = true
        loader.style = .large
        return loader
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupElements() {
        
        // добавим на вью
        addSubview(myLabel)
        addSubview(loader)
        
        // закрепим с помощью констрейнтов через код
        loader.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        loader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        // у trailingAnchor надо делать -20.
        // почему используется leading and trailing слова. Потому что в разных странах лево и право, не всегда лево и право.
        loader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        myLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        // это говорит о том, что label будет на 8 пойнтов ниже loader
        myLabel.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 8).isActive = true
    }
    
    func showLoader() {
        loader.startAnimating()
        myLabel.text = "LOADING"
    }

    func hideLoader() {
        loader.stopAnimating()
        myLabel.text = ""
    }
}
