## The position of the entity
class_name Component_Position extends EcsComponentBase
const NAME = &"Position"

## Coordinate position
var position: Vector2 = Vector2.ZERO

## Direction, Range -1 to 1
var direction: Vector2i = Vector2i.ZERO

var speed = 300
