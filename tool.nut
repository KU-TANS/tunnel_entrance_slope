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

function get_desc(waytype,name) {
	local sts = [st_flat, st_elevated, st_tram]
	foreach (st in sts) {
		local desc_all = way_desc_x.get_available_ways(waytype, st)
		foreach (desc in desc_all) {
			if(desc.get_name()==name) {
				return desc
			}
		}
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
	local tile = tile_x(tp.x,tp.y,tp.z)
	if(!tile.is_ground() || !tile.has_ways()) {
		return "Tile " + tp.tostring() + " is not a valid ground!"
	}
	local tp = pos+coord3d(0,0,-3)
	local tile = tile_x(tp.x,tp.y,tp.z)
	if((!tile.is_ground() || !tile.has_ways()) && tile.get_slope() != 0) {
		return "Tile " + tp.tostring() + " is not a valid ground!"
	}
	local tp = pos+coord3d(0,0,-4)
	local tile = tile_x(tp.x,tp.y,tp.z)
	if((!tile.is_ground() || !tile.has_ways()) && (tile.get_slope() == 8 || tile.get_slope() == 24 || tile.get_slope() == 56 || tile.get_slope() == 72)) {
		return "Tile " + tp.tostring() + " is not a valid ground!"
	}

	local map_obj = map_object_x(pos.x,pos.y,pos.z,mo_way)

	local name = map_obj.get_name()
	local waytype = map_obj.get_waytype()

	local direction = tile.get_way_dirs(waytype)

	local desc = get_desc(waytype, name)
	local start = pos+coord3d(0,0,-1)

	local tp_x
	local tp_y
	local slope

	// 下方向
	if(direction == 1){
		tp_x = 0
		tp_y = 1
		slope = 8
	}

	// 左方向
	else if(direction == 2){
		tp_x = -1
		tp_y = 0
		slope = 56
	}

	// 上方向
	else if(direction == 4){
		tp_x = 0
		tp_y = -1
		slope = 72
	}

	// 右方向
	else if(direction == 8){
		tp_x = 1
		tp_y = 0
		slope = 24
	}
	else{
		return "Not direction or Not applicable way"
	}

	local tp = pos+coord3d(tp_x,tp_y,-4)
	local err = collate_tile(pos,tp)
	if(err!=null) {
		return err
	}

	local tp = pos+coord3d(tp_x*2,tp_y*2,-4)
	local err = collate_tile(pos,tp)
	if(err!=null) {
		return err
	}

	command_x.set_slope(player, pos, 83)

	local tp = pos+coord3d(tp_x,tp_y,-1)
	make_slope(player,tp)
	command_x.build_way(player, start, tp, desc, true)
	command_x.set_slope(player, tp, 83)

	local tp = pos+coord3d(tp_x*2,tp_y*2,-2)
	make_slope(player,tp)
	command_x.set_slope(player, tp, slope)
}
