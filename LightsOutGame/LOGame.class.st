Class {
	#name : #LOGame,
	#superclass : #BorderedMorph,
	#instVars : [
		'cells',
		'moves',
		'label'
	],
	#classVars : [
		'GamesLaunched',
		'N',
		'TheGame'
	],
	#category : #LightsOutGame
}

{ #category : #'initialize-release' }
LOGame class >> close [
	TheGame ifNil: [ ^ self ].
	TheGame delete.
	TheGame := nil
]

{ #category : #'world menu' }
LOGame class >> menuCommandOn: aBuilder [
  <worldMenu>
(aBuilder item: #'LOGame')
 order: 5;
 with: [
  (aBuilder item: #'Run Game')
    order: 0;
    action: [self open].
	(aBuilder item: #'Restart Game')
	 order: 1;
	 action: [self restart].
  (aBuilder item: #'Exit Game')
    order: 2;
    action: [self close].
	(aBuilder item: #'Grid Size')
	order: 3;
	with:
	[ 
	(aBuilder item: #'2')
	order:1;
	action: [ N := 2 ].
	(aBuilder item: #'4')
	order:2;
	action: [ N := 4 ].
	(aBuilder item: #'10')
	order:3;
	action: [ N := 10 ].
	 ].
	(aBuilder item: #'Number of games opened')
	 order: 4;
	 action: [self showNumberOfStarts].].
]

{ #category : #'world menu' }
LOGame class >> open [
	TheGame ifNotNil: [ ^self ].
	self openGame.
]

{ #category : #'as yet unclassified' }
LOGame class >> openGame [
"Відкриття гри, винесене за межі інших функцій для інкрементування кількості запусків гри"
	TheGame:= self new.
	TheGame openInWorld.
	GamesLaunched ifNil: [ ^GamesLaunched := 1 ].
	GamesLaunched := GamesLaunched + 1.
]

{ #category : #starting }
LOGame class >> restart [
"Перезапуск гри (закриття і відкриття, якщо вона була відкрита)"
	TheGame ifNil: [ ^ self ].
	TheGame delete.
	self openGame.
]

{ #category : #'as yet unclassified' }
LOGame class >> showNumberOfStarts [
| n |
"Вивід на екран кількості запусків гри"
	GamesLaunched ifNil: [ n := 0 ] ifNotNil: [ n := GamesLaunched  ].
	UIManager default alert: 'The game was opened ', n printString, ' time(s).'
]

{ #category : #'as yet unclassified' }
LOGame >> cellsPerSide [
"The number of cells along each side of the game"
"Використання наданого методу для можливості зміни розміру грального поля"
N ifNil: [ ^ 10 ].
^ N.
]

{ #category : #'as yet unclassified' }
LOGame >> disableCells [
"Закриття доступу до зміни поля (використовується після виграшу)"
	cells do: [ :cell | cell mouseAction: [nil]].
]

{ #category : #'as yet unclassified' }
LOGame >> gameWon [
"Метод, що інформує гравця про перемогу, та закриває доступ до зміни поля."
	UIManager default alert: 'You won, using ', moves printString , ' moves! Congradulations!!!'.
	self disableCells.
]

{ #category : #initialization }
LOGame >> initialize [
 | sampleCell width height n |
super initialize.
self color: Color white.
n := self cellsPerSide.
sampleCell := LOCell new.
width := sampleCell width.
height := sampleCell height.
self bounds: (50@50 extent: ((width*n) @(height*n)) + (5 * self borderWidth) + (0@25)).
cells := Array2D  new: n tabulate: [ :i :j | self newCellAt: i at: j ].
moves := 0.
label := 'Moves used: 0' asMorph.
self addMorph: label.
label position: 0 @ (n * sampleCell height) +  55.
]

{ #category : #accessing }
LOGame >> mouseEventAt: i at: j [
"Розширення наданого методу - крім перемикання станів, рахує кількість ходів та робить перевірку на перемогу"
self toggleNeighboursOfCellAt: i at: j.
self movesIncrement.
self winCheck ifTrue: [ self gameWon ]. 
]

{ #category : #'as yet unclassified' }
LOGame >> movesIncrement [
"Підрахунок кількості ходів, та інформування гравця про це."
moves := moves + 1.
label contents: 'Moves used: ', moves printString. 
]

{ #category : #accessing }
LOGame >> newCellAt: i at: j [
"Create a cell for position (i,j) and add it to my on?screen
representation at the appropriate screen position. Answer the new cell"
| c origin |
c := LOCell new.
origin := self innerBounds origin.
self addMorph: c.
c position: ((i - 1) * c width) @ ((j - 1) * c height) + origin.
c mouseAction: [self mouseEventAt: i at: j].
^c
]

{ #category : #accessing }
LOGame >> toggleNeighboursOfCellAt: i at: j [
(i > 1) ifTrue: [ (cells at: i - 1 at: j ) toggleState].
(i < self cellsPerSide) ifTrue: [ (cells at: i + 1 at: j) toggleState].
(j > 1) ifTrue: [ (cells at: i at: j - 1) toggleState].
(j < self cellsPerSide) ifTrue: [ (cells at: i at: j + 1) toggleState].

]

{ #category : #'as yet unclassified' }
LOGame >> winCheck [
"Умова перемоги - всі клітинки 'увімкнені'"
	^ cells allSatisfy: [ :cell | cell isOn ].
]
