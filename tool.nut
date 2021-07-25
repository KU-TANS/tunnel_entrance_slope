function work(player, pos) {
	local pos_tile = tile_x(pos.x, pos.y, pos.z)
	local err
	if(!pos_tile.is_ground() || !pos_tile.has_ways()) {
		return "Tile " + pos.tostring() + " is not a valid ground!"
	}
	else if(pos_tile.get_slope() != 0) {
		return "Please use on flat ground"
	}
	else if(err = command_x.can_set_slope(player, pos, 83)) {
		return err
	}


	local waytype = pos_tile.find_object(mo_way).get_waytype()
	local direction = pos_tile.get_way_dirs(waytype)

	if(!dir.is_single(direction)){
		// dirが一方向ではないとき
		return "Please use single direction"
	}
	else if(waytype == 1 && pos_tile.has_way(wt_rail) && pos_tile.get_way_dirs(wt_rail) != direction){
		// 道路と路面軌道のdirが異なるとき
		return "Direction is not match"
	}

	local back_dir = dir.backward(direction)
	local diff = dir.to_coord(back_dir)

	err = collate_tile(pos, diff)
	if(err) {
		return err
	}

	err = collate_tile(pos, diff*2)
	if(err) {
		return err
	}

	command_x.set_slope(player, pos, 83)

	local first_tp = pos + diff
	local desc = pos_tile.find_object(mo_way).get_desc()
	local start = pos + coord3d(0, 0, -1)
	local first_ground_tile = square_x(first_tp.x, first_tp.y).get_ground_tile()
	if(first_ground_tile.z == pos.z - 2){
		// 隣のマスのheightが-2のとき
		first_tp.z -= 2
		if(first_ground_tile.get_slope() != dir.to_slope(direction)){
			command_x.set_slope(player, first_tp, dir.to_slope(direction))
		}
		command_x.build_way(player, start, first_tp, desc, true)
	}
	else{
		first_tp.z--
		make_slope(player, first_tp, first_ground_tile)
		command_x.build_way(player, start, first_tp, desc, true)
		command_x.set_slope(player, first_tp, 83)
	}


	local second_tp = pos + diff*2 + coord3d(0, 0, -2)
	make_slope(player, second_tp, square_x(second_tp.x, second_tp.y).get_ground_tile())

	local slope = dir.to_slope(back_dir) * 2
	command_x.set_slope(player, second_tp, slope)
}


function collate_tile(pos, diff) {
	local tp = pos + diff
	local height = square_x(tp.x, tp.y).get_ground_tile().z
	local target = pos.z - 5
	if(target + 3 > height){
		return coord3d(tp.x, tp.y, height).tostring() + " is low"
	}

	while(height >= target){
		local tile = tile_x(tp.x, tp.y, height)
		if(!tile.is_empty() && is_already_use(tile.get_slope(), height, target)) {
			return "Tile " + coord3d(tp.x, tp.y, height).tostring() + " is already in use!"
		}
		height--
	}
}

function make_slope(player, tp, ground_tile){
	local tile_pos = coord3d(tp.x, tp.y, ground_tile.z)
	if(ground_tile.get_slope() != 0){
		command_x.set_slope(player, tile_pos, 83)
	}
	while(tile_pos.z > tp.z){
		command_x.set_slope(player, tile_pos, 83)
		tile_pos.z--
	}
}

function is_double_height(dir){
	if(dir == 8 || dir == 24 || dir == 56 || dir == 72){
		return true
	}
	else{
		return false
	}
}

function is_already_use(dir, height, target){
	if (height > target + 1 || (height == target + 1 && dir != 0) || (height == target && is_double_height(dir))){
		return true
	}
	else{
		return false
	}
}
