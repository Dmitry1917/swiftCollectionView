//
//  TIRVIPERPresenter.swift
//  ThreeInRow
//
//  Created by DMITRY SINYOV on 21.08.17.
//  Copyright © 2017 DMITRY SINYOV. All rights reserved.
//

import UIKit

class TIRVIPERViewModelElement: NSObject
{
    var type: TIRElementMainTypes = .elementUndefined
    var row: Int = 0
    var column: Int = 0
    
    init(modelElement: TIRVIPERModelElement)
    {
        self.type = modelElement.elementType
        self.row = modelElement.coordinates.row
        self.column = modelElement.coordinates.column
    }
}

protocol TIRVIPERPresenterToViewProtocol: class {
    func setField(newField: [[TIRVIPERViewModelElement]], reloadNow: Bool)
    func chooseCell(coord:(row: Int, column: Int))
    func animateUnsuccessfullSwap(first: (row: Int, column: Int), second: (row: Int, column: Int))
    func animateSuccessfullSwap(first: (row: Int, column: Int), second: (row: Int, column: Int))
}

protocol TIRVIPERPresenterFromViewProtocol
{
    func prepareFieldPresentation()
    func swapElementsByCoordsIfCan(first: (row: Int, column: Int), second: (row: Int, column: Int))
    
    func useGravityOnField()
    func refillFieldByColumns() -> [[TIRVIPERViewModelElement]]
    func elementByCoord(row: Int, column: Int) -> TIRVIPERViewModelElement?
    func moveElementFromTo(row1: Int, column1: Int, row2: Int, column2: Int)
    
    func removeThreesAndMore()
}

//презентер не должен знать об индексах таблицы//
//презентер не является просто передатчиком из view в model за редким исключением, иначе что-то неверно в архитектуре
//то что анимация идёт, известно presenter, но сами анимационные действия только в view//
//закешированные картинки для анимаций создаёт и хранит view//
//view не знает об устройстве модели и не работает с объектами, напримую полученными из неё//

class TIRVIPERPresenter: NSObject, TIRVIPERPresenterFromViewProtocol
{
    unowned var view: TIRVIPERViewProtocol & TIRVIPERPresenterToViewProtocol
    var interactor: TIRVIPERInteractorFromPresenterProtocol!
    
    var itemsPerRow: Int { get { return interactor.itemsPerRow } }
    var rowsCount: Int { get { return interactor.rowsCount } }
    
    init(view: TIRVIPERViewProtocol & TIRVIPERPresenterToViewProtocol, interactor: TIRVIPERInteractorFromPresenterProtocol)
    {
        self.view = view
        self.interactor = interactor
        
        self.interactor.setupModel()
    }
    
    func prepareFieldPresentation() {
        
        var fieldViewModel = [[TIRVIPERViewModelElement]]()
        
        for row in 0..<interactor.rowsCount {
            var elementRow = [TIRVIPERViewModelElement]()
            for column in 0..<interactor.itemsPerRow {
                guard let element = elementByCoord(row: row, column: column) else { continue }
                elementRow.append(element)
            }
            fieldViewModel.append(elementRow)
        }
        
        view.setField(newField: fieldViewModel, reloadNow: true)
    }
    
    func swapElementsByCoordsIfCan(first: (row: Int, column: Int), second: (row: Int, column: Int))
    {
        let firstRowColumn = TIRRowColumn(row: first.row, column: first.column)
        let secondRowColumn = TIRRowColumn(row: second.row, column: second.column)
        if interactor.canTrySwap(fromCoord: firstRowColumn, toCoord: secondRowColumn)
        {
            if interactor.canSwap(fromCoord: firstRowColumn, toCoord: secondRowColumn)
            {
                interactor.swapElementsByCoords(firstCoord: firstRowColumn, secondCoord: secondRowColumn)
                view.animateSuccessfullSwap(first: first, second: second)
            }
            else
            {
                view.animateUnsuccessfullSwap(first: first, second: second)
            }
        }
        else
        {
            view.chooseCell(coord: second)
        }
    }
    
    func removeThreesAndMore()
    {
        let chainsForRemove = findChains()
        
        guard chainsForRemove.count > 0 else {
            view.animationSequenceStoped()
            return
        }
        
        //подготовка к анимации удаления
        var removingElements = [TIRVIPERViewModelElement]()
        for chain in chainsForRemove
        {
            for modelElement in chain
            {
                removingElements.append(TIRVIPERViewModelElement(modelElement: modelElement))
            }
        }
        
        removeChains(chains: chainsForRemove)
        
        view.animateElementsRemove(elements: removingElements, completion: {
            self.useGravityOnField()
        })
    }
    
    func findChains() -> [[TIRVIPERModelElement]]
    {
        return interactor.findChains()
    }
    func removeChains(chains: [[TIRVIPERModelElement]])
    {
        return interactor.removeChains(chains: chains)
    }
    func useGravityOnField()
    {
        let (oldCoords, newCoords) = interactor.useGravityOnField()
        
        let oldViewCoords: [(row: Int, column: Int)] = oldCoords.map
        { (coord) -> (row: Int, column: Int) in
            
            return (row: coord.row, column: coord.column)
        }
        let newViewCoords: [(row: Int, column: Int)] = newCoords.map
        { (coord) -> (row: Int, column: Int) in
            
            return (row: coord.row, column: coord.column)
        }
        
        let refillHandler = {
            
            let refilledColumns = self.refillFieldByColumns()
            self.view.animateFieldRefill(columns: refilledColumns)
        }
        
        view.animateFieldChanges(oldViewCoords: oldViewCoords, newViewCoords: newViewCoords, completionHandler: refillHandler)
    }
    
    func refillFieldByColumns() -> [[TIRVIPERViewModelElement]]
    {
        return interactor.refillFieldByColumns().map {
            (columnElements) -> [TIRVIPERViewModelElement] in
            
            let columnViewElements = columnElements.map {
                (modelElement) -> TIRVIPERViewModelElement in
                
                return TIRVIPERViewModelElement(modelElement: modelElement)
            }
            return columnViewElements
        }
    }
    func elementByCoord(row: Int, column: Int) -> TIRVIPERViewModelElement?
    {
        guard let elementModel = interactor.elementByCoord(coord: TIRRowColumn(row: row, column: column)) else { return nil }
        let elementView = TIRVIPERViewModelElement(modelElement: elementModel)
        return elementView
    }
    func moveElementFromTo(row1: Int, column1: Int, row2: Int, column2: Int)
    {
        return interactor.swapElementsByCoords(firstCoord: TIRRowColumn(row: row1, column: column1), secondCoord: TIRRowColumn(row: row2, column: column2))
    }
}

extension TIRVIPERPresenter: TIRVIPERInteractorToPresenterProtocol {
}
