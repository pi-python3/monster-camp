extends Object

class PathNode:
	var pos: Vector2;
	var parent: PathNode
	var g_cost: int;
	var h_cost: int;
	var traversable : bool;
	
	func init(node_pos: Vector2, type: String):
		self.pos = node_pos;
		self.traversable = not (type in ["red", "blue"]);
	
	
	func get_f_cost() -> int:
		return int(g_cost + h_cost);
