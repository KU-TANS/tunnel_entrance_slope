function collate_tile(pos,tp) {
	local height = square_x(tp.x, tp.y).get_ground_tile().z
	if(pos.z > height){
		return coord3d(tp.x,tp.y,height).tostring() + " is low"
	}
	local tile = tile_x(tp.x,tp.y,height)
	local slope_ground = tile.get_slope()
	while(height >= tp.z){
		local slope_direction = tile.get_slope()
		local is_tile_empty = tile.is_empty()
		if(!is_tile_empty && height > tp.z + 1) {
			return "Tile " + coord3d(tp.x,tp.y,height).tostring() + " is not a valid ground!"
		}
		else if(!is_tile_empty && height == tp.z + 1 && slope_direction != 0){
			return "Tile " + coord3d(tp.x,tp.y,height).tostring() + " is not a valid ground!"
		}
		else if(!is_tile_empty && height == tp.z && (slope_direction == 8 || slope_direction == 24 || slope_direction == 56 || slope_direction == 72)){
			return "Tile " + coord3d(tp.x,tp.y,height).tostring() + " is not a valid ground!"
		}
		height--
		tile = tile_x(tp.x,tp.y,height)
	}
}

function make_slope(player,tp){
	local height = square_x(tp.x, tp.y).get_ground_tile().z
	local tile = tile_x(tp.x, tp.y, height)
	local target = coord3d(tp.x,tp.y,height)
	if(tile.get_slope() != 0){
		command_x.set_slope(player, target, 83)
	}
	while(height > tp.z){
		command_x.set_slope(player, target, 83)

		height--
		target = coord3d(tp.x,tp.y,height)
	}
}


function work(player, pos) {
	local tile = tile_x(pos.x, pos.y, pos.z)
	if(!tile.is_ground() || !tile.has_ways()) {
		return "Tile " + pos.tostring() + " is not a valid ground!"
	}
	if(tile.get_slope() != 0){
		return "Please use on flat ground"
	}

 	local tp = pos+coord3d(0,0,-2)
	tile = tile_x(tp.x,tp.y,tp.z)
	if(!tile.is_ground() || !tile.has_ways()) {
		return "Tile " + tp.tostring() + " is not a valid ground!"
	}
	tp = pos+coord3d(0,0,-3)
	tile = tile_x(tp.x,tp.y,tp.z)
	if((!tile.is_ground() || !tile.has_ways()) && tile.get_slope() != 0) {
		return "Tile " + tp.tostring() + " is not a valid ground!"
	}
	tp = pos+coord3d(0,0,-4)
	tile = tile_x(tp.x,tp.y,tp.z)
	if((!tile.is_ground() || !tile.has_ways()) && (tile.get_slope() == 8 || tile.get_slope() == 24 || tile.get_slope() == 56 || tile.get_slope() == 72)) {
		return "Tile " + tp.tostring() + " is not a valid ground!"
	}

	local map_obj = map_object_x(pos.x,pos.y,pos.z,mo_way)
	local waytype = map_obj.get_waytype()

	local direction = tile.get_way_dirs(waytype)

	local tp_x
	local tp_y
	local slope

	// ?????????
	if(direction == 1){
		tp_x = 0
		tp_y = 1
		slope = 8
	}

	// ?????????
	else if(direction == 2){
		tp_x = -1
		tp_y = 0
		slope = 56
	}

	// ?????????
	else if(direction == 4){
		tp_x = 0
		tp_y = -1
		slope = 72
	}

	// ?????????
	else if(direction == 8){
		tp_x = 1
		tp_y = 0
		slope = 24
	}
	else{
		return "Not direction or Not applicable way"
	}

	tp = pos+coord3d(tp_x,tp_y,-4)
	local err = collate_tile(pos,tp)
	if(err!=null) {
		return err
	}

	tp = pos+coord3d(tp_x*2,tp_y*2,-4)
	err = collate_tile(pos,tp)
	if(err!=null) {
		return err
	}

	command_x.set_slope(player, pos, 83)

	tp = pos+coord3d(tp_x,tp_y,-1)
	make_slope(player,tp)

	tile = tile_x(pos.x, pos.y, pos.z)
	local desc = tile.find_object(mo_way).get_desc()
	local start = pos+coord3d(0,0,-1)

	command_x.build_way(player, start, tp, desc, true)
	command_x.set_slope(player, tp, 83)


	tp = pos+coord3d(tp_x*2,tp_y*2,-2)
	make_slope(player,tp)
	command_x.set_slope(player, tp, slope)
}
