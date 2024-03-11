extends Node
class_name StateMachine



@export var startingState: int

var stateNodes: Array[State] = []
var stateNames: Array[String] = []
var currentState: int


func _ready():
	
	for child in get_children():
		if child is State:
			stateNodes.append(child)
			stateNames.append(child.name)
			child.process_mode = Node.PROCESS_MODE_DISABLED
			
		
	stateNodes[startingState].process_mode = Node.PROCESS_MODE_INHERIT
	currentState = startingState
	

	
	
	
func changeState(index: int):
	stateNodes[currentState].process_mode = Node.PROCESS_MODE_DISABLED
	stateNodes[index].process_mode = Node.PROCESS_MODE_INHERIT
	currentState = index
	
func changeStateByName(title: String):
	changeState(stateNames.find(title))
		

func getCurrentState() -> State:
	return stateNodes[currentState]
