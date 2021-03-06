
# == title
# The Class for Legends
#
# == details
# This is a very simple class for legends that it only has one slot which is the real `grid::grob` of the legends. 
#
# Construct a single legend by `Legend` and a group of legends by `packLegend`.
# 
# == example
# lgd = Legend(at = 1:4)
# lgd
# lgd@grob
Legends = setClass("Legends",
    slots = list(
        grob = "ANY",
        type = "character",
        n = "numeric"
    )
)

# == title
# Constructor method for Legends class
#
# == param
# -... arguments.
#
# == details
# There is no public constructor method for the `Legends-class`.
#
# == value
# No value is returned.
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
Legends = function(...) {
    new("Legends", ...)
}

# == title
# Make a Single Legend
#
# == param
# -at Breaks of the legend. The values can be either numeric or character. If it is not specified,
#     the values of ``labels`` are taken as labels.
# -labels Labels corresponding to ``at``. If it is not specified, the values of ``at`` are taken as labels.
# -col_fun A color mapping function which is used to make a continuous legend. Use `circlize::colorRamp2` to
#     generate the color mapping function. If ``at`` is missing, the breaks recorded in the color mapping function
#      are used for ``at``.
# -nrow For legend which is represented as grids, ``nrow`` controls number of rows of the grids if the grids
#      are arranged into multiple rows.
# -ncol Similar as ``nrow``, ``ncol`` controls number of columns of the grids if the grids
#      are arranged into multiple columns. Note at a same time only one of ``nrow`` and ``ncol`` can be specified.
# -by_row Are the legend grids arranged by rows or by columns?
# -grid_height The height of legend grid. It can also control the height of the continuous legend if it is horizontal.
# -grid_width The width of legend grid. It can also control the width of the continuous legend if it is vertical.
# -gap If legend grids are put into multiple rows or columns, this controls the gap between neighbouring rows or columns, measured as a `grid::unit` object.
# -labels_gp Graphic parameters for labels.
# -labels_rot Text rotation for labels. It should only be used for horizontal continuous legend.
# -border Color of legend grid borders. It also works for the ticks in the continuous legend.
# -background Background colors for the grids. It is used when points and lines are the legend graphics.
# -type Type of legends. The value can be one of ``grid``, ``points`` and ``lines``.
# -legend_gp Graphic parameters for the legend grids. You should control the filled color of the legend grids by ``gpar(fill = ...)``.
# -pch Type of points if points are used as legend. Note you can use single-letter as pch, e.g. ``pch = 'A'``.
# -size Size of points.
# -legend_height Height of the whole legend body. It is only used for vertical continous legend.
# -legend_width Width of the whole legend body. It is only used for horizontal continous legend.
# -direction Direction of the legend, vertical or horizontal?
# -title Title of the legend.
# -title_gp Graphic parameters of the title.
# -title_position Position of title relative to the legend. ``topleft``, ``topcenter``, ``leftcenter-rot``
#     and ``lefttop-rot`` are only for vertical legend and ``leftcenter``, ``lefttop`` are only for 
#     horizontal legend.
#
# == details
# Most of the argument can also be set in ``heatmap_legend_param`` argument in `Heatmap` or ``annotation_legend_param``
# argument in `HeatmapAnnotation` to configure legend styles for heatmap and annotations.
#
# == seealso
# `packLegend` packs multiple legends into one `Legends-class` object.
#
# See examples of configuring legends: https://jokergoo.github.io/ComplexHeatmap-reference/book/legends.html
#
# == value
# A `Legends-class` object.
#
# == example
# lgd = Legend(labels = month.name[1:6], title = "foo", legend_gp = gpar(fill = 1:6))
# draw(lgd, test = "add labels and title")
#
# require(circlize)
# col_fun = colorRamp2(c(0, 0.5, 1), c("blue", "white", "red"))
# lgd = Legend(col_fun = col_fun, title = "foo")
# draw(lgd, test = "only col_fun")
#
# col_fun = colorRamp2(c(0, 0.5, 1), c("blue", "white", "red"))
# lgd = Legend(col_fun = col_fun, title = "foo", at = c(0, 0.1, 0.15, 0.5, 0.9, 0.95, 1))
# draw(lgd, test = "unequal interval breaks")
Legend = function(at, labels = at, col_fun, nrow = NULL, ncol = 1, by_row = FALSE,
	grid_height = unit(4, "mm"), grid_width = unit(4, "mm"), gap = unit(2, "mm"),
	labels_gp = gpar(fontsize = 10), labels_rot = 0,
	border = NULL, background = "#EEEEEE",
	type = "grid", legend_gp = gpar(),
	pch = 16, size = unit(2, "mm"),
	legend_height = NULL, legend_width = NULL,
	direction = c("vertical", "horizontal"),
	title = "", title_gp = gpar(fontsize = 10, fontface = "bold"),
	title_position = c("topleft", "topcenter", "leftcenter", "lefttop", "leftcenter-rot", "lefttop-rot")) {

	dev.null()
	on.exit(dev.off2())

	if(missing(at) && !missing(labels)) {
		at = seq_along(labels)
	}

	if(!"fontsize" %in% names(labels_gp)) {
		labels_gp$fontsize = 10
	}

	# odevlist = dev.list()
	direction = match.arg(direction)[1]
	title_position = match.arg(title_position)[1]
	title_padding = unit(1.5, "mm")
	if(missing(col_fun)) {
		if(is.null(border)) border = "white"
		legend_body = discrete_legend_body(at = at, labels = labels, nrow = nrow, ncol = ncol,
			grid_height = grid_height, grid_width = grid_width, gap = gap, labels_gp = labels_gp,
			border = border, background = background, type = type, legend_gp = legend_gp,
			pch = pch, size = size, by_row = by_row)
	} else {
		if(!missing(col_fun) && missing(at)) {
			breaks = attr(col_fun, "breaks")
			if(is.null(breaks)) {
				stop_wrap("You should provide `at` for color mapping function\n")
			}
		
			le1 = grid.pretty(range(breaks))
			le2 = pretty(breaks, n = 3)
			if(abs(length(le1) - 5) < abs(length(le2) - 5)) {
				at = le1
			} else {
				at = le2
			}
		}
		if(direction == "vertical") {
			legend_body = vertical_continuous_legend_body(at = at, labels = labels, col_fun = col_fun,
				grid_height = grid_height, grid_width = grid_width, legend_height = legend_height,
				labels_gp = labels_gp, border = border)
		} else {
			legend_extension = unit(0, "mm")
			if(title_position == "lefttop") {
				title_width = convertWidth(grobWidth(textGrob(title, gp = title_gp)), "mm")
				title_height = convertHeight(grobHeight(textGrob(title, gp = title_gp)), "mm")
				if(title_height[[1]] <= grid_height[[1]]) {
					legend_extension = title_width + title_padding
				}
			}
			legend_body = horizontal_continuous_legend_body(at = at, labels = labels, col_fun = col_fun,
				grid_height = grid_height, grid_width = grid_width, legend_width = legend_width,
				labels_gp = labels_gp, labels_rot = labels_rot, border = border, legend_extension = legend_extension)
		}
	}

	if(is.null(title)) {
		object = new("Legends")
		object@grob = legend_body
		object@type = "single_legend_no_title"
		object@n = 1
		return(object)
	}
	if(!inherits(title, c("expression", "call"))) {
		if(title == "") {
			object = new("Legends")
			object@grob = legend_body
			object@type = "single_legend_no_title"
			object@n = 1
			return(object)
		}
	}

	title_grob = textGrob(title, gp = title_gp)
	title_height = convertHeight(grobHeight(title_grob), "mm")
	title_width = convertWidth(grobWidth(title_grob), "mm")

	legend_width = convertWidth(grobWidth(legend_body), "mm")
	legend_height = convertHeight(grobHeight(legend_body), "mm")

	# at the top level, create a global viewport
	if(!missing(col_fun)) {
		if(direction == "vertical") {
			if(title_position %in% c("leftcenter", "lefttop")) {
				stop_wrap("'topleft', 'topcenter', 'leftcenter-rot' and 'lefttop-rot' are only allowd for vertical continuous legend")
			}
		}
		if(direction == "horizontal") {
			if(title_position %in% c('leftcenter-rot', 'lefttop-rot')) {
				stop_wrap("'topleft', 'topcenter', 'lefttop' and 'leftcenter' are only allowd for horizontal continuous legend")
			}
		}
	}

	if(title_position %in% c("topleft", "topcenter")) {
		if(title_width > legend_width && title_position == "topleft") {
			total_width = title_width
			total_height = title_height + title_padding + legend_height
			
			title_x = unit(0, "npc")
			title_just = c("left", "top")
		} else {
			total_width = legend_width
			total_height = title_height + title_padding + legend_height

			if(title_position == "topleft") {
				title_x = unit(0, "npc")
				title_just = c("left", "top")
			} else {
				title_x = unit(0.5, "npc")
				title_just = "top"
			}
		}
		gf = grobTree(
			textGrob(title, x = title_x, y = unit(1, "npc"), just = title_just, gp = title_gp),
			edit_vp_in_legend_grob(legend_body, x = unit(0, "npc"), y = unit(0, "npc"), valid.just = c(0, 0)),
			vp = viewport(width = total_width, height = total_height),
			cl = "legend"
		)
		attr(gf, "width") = total_width
		attr(gf, "height") = total_height
		
	} else if(title_position %in% c("leftcenter", "lefttop")) {
		if(title_height > legend_height && title_position == "lefttop") {
			total_width = title_width + title_padding + legend_width
			total_height = title_height
			
			title_y = unit(1, "npc")
			title_just = c("left", "top")
		} else {
			total_width = title_width + title_padding + legend_width
			total_height = legend_height
			if(title_position == "lefttop") {
				title_y = unit(1, "npc")
				title_just = c("left", "top")
			} else {
				title_y = unit(0.5, "npc")
				title_just = "left"
			}
		}
		gf = grobTree(
			textGrob(title, x = unit(0, "npc"), y = title_y, just = title_just, gp = title_gp),
			edit_vp_in_legend_grob(legend_body, x = unit(1, "npc"), y = unit(1, "npc"), 
				valid.just = c(1, 1)),
			vp = viewport(width = total_width, height = total_height),
			cl = "Legend"
		)
		attr(gf, "width") = total_width
		attr(gf, "height") = total_height
	} else if(title_position %in% c("leftcenter-rot", "lefttop-rot")) {
		if(title_width > legend_height && title_position == "lefttop-rot") {
			total_width = title_height + title_padding + legend_width
			total_height = title_width
			
			title_y = unit(1, "npc")
			title_just = c("right", "top")
		} else {
			total_width = title_height + title_padding + legend_width
			total_height = legend_height
			if(title_position == "lefttop-rot") {
				title_y = unit(1, "npc")
				title_just = c("right", "top")
			} else {
				title_y = unit(0.5, "npc")
				title_just = "top"
			}
		}
		gf = grobTree(
			textGrob(title, x = unit(0, "npc"), y = title_y, just = title_just, gp = title_gp, rot = 90),
			edit_vp_in_legend_grob(legend_body, x = unit(1, "npc"), y = unit(1, "npc"), 
				valid.just = c(1, 1)),
			vp = viewport(width = total_width, height = total_height),
			cl = "legend"
		)
		attr(gf, "width") = total_width
		attr(gf, "height") = total_height
	}

	object = new("Legends")
	object@grob = gf
	object@type = "single_legend"
	object@n = 1
	return(object)
}

setMethod("show",
	signature = "Legends",
	definition = function(object) {
	if(object@type == "single_legend") {
		cat("A single legend\n")
	} else if(object@type == "single_legend_no_title") {
		cat("A single legend without title\n")
	} else {
		cat("A pack of", object@n, "legends\n")
	}
})

widthDetails.Legend = function(x) {
	attr(x, "width")
}

heightDetails.Legend = function(x) {
	attr(x, "height")
}

# grids are arranged by rows or columns
discrete_legend_body = function(at, labels = at, nrow = NULL, ncol = 1, by_row = TRUE,
	grid_height = unit(4, "mm"), grid_width = unit(4, "mm"), gap = unit(2, "mm"),
	labels_gp = gpar(fontsize = 10),
	border = "white", background = "#EEEEEE",
	type = "grid", legend_gp = gpar(),
	pch = 16, size = unit(2, "mm")) {

	n_labels = length(labels)
	if(is.null(nrow)) {
		nrow = ceiling(n_labels / ncol)
	} else {
		ncol = ceiling(n_labels / nrow)
	}
	if(length(at) == 1) {
		nrow = 1
		ncol = 1
	}
	ncol = ifelse(ncol > n_labels, n_labels, ncol)

	labels_mat = matrix(c(labels, rep("", nrow*ncol - n_labels)), nrow = nrow, ncol = ncol, byrow = by_row)
	index_mat = matrix(1:(nrow*ncol), nrow = nrow, ncol = ncol, byrow = by_row)

	labels_padding_left = unit(1, "mm")

	## max width for each column in the legend
	labels_max_width = NULL
	for(i in 1:ncol) {
		if(i == 1) {
			labels_max_width = max(do.call("unit.c", lapply(labels_mat[, i], function(x) {
					g = grobWidth(textGrob(x, gp = labels_gp))
					if(i < ncol) {
						g = g + gap
					}
					g
				})))
		} else {
			labels_max_width = unit.c(labels_max_width, max(do.call("unit.c", lapply(labels_mat[, i], function(x) {
					g = grobWidth(textGrob(x, gp = labels_gp))
					if(i < ncol) {
						g = g + gap
					}
					g
				}))))
		}
	}
	labels_max_width = convertWidth(labels_max_width, "mm")

	legend_gp = recycle_gp(legend_gp, n_labels)

	legend_body_width = grid_width*ncol + labels_padding_left*ncol + sum(labels_max_width)
	legend_body_height = nrow*(grid_height)
	legend_body_width = convertWidth(legend_body_width, "mm")
	legend_body_height = convertHeight(legend_body_height, "mm")

	# legend grid
	gl = list()
	for(i in 1:ncol) {
		index = index_mat[, i][labels_mat[, i] != ""]
		ni = length(index)
		y = (0:(ni-1))*(grid_height)
		y = legend_body_height - y

		labels_x = grid_width*i + sum(labels_max_width[1:i]) + labels_padding_left*i - labels_max_width[i]
		labels_y = y - grid_height*0.5
		labels_x = convertWidth(labels_x, "mm")
		labels_y = convertHeight(labels_y, "mm")
		gl = c(gl, list(
			textGrob(labels[index], x = labels_x, y = labels_y, just = "left", gp = labels_gp)
		))

		# grid
		sgd = subset_gp(legend_gp, index)
		sgd2 = gpar()
		if("grid" %in% type) {
			sgd2$fill = sgd$fill
		} else {
			sgd2$fill = background
		}
		sgd2$col = border

		grid_x = grid_width*i + sum(labels_max_width[1:i]) + labels_padding_left*i - labels_max_width[i] - labels_padding_left - grid_width*0.5
		grid_y = y - grid_height*0.5
		grid_x = convertWidth(grid_x, "mm")
		grid_x = rep(grid_x, length(grid_y))
		grid_y = convertHeight(grid_y, "mm")

		gl = c(gl, list(
			rectGrob(x = grid_x, y = grid_y, width = grid_width, height = grid_height, gp = sgd2)
		))

		if(any(c("points", "p") %in% type)) {
			if(length(pch) == 1) pch = rep(pch, n_labels)
			if(length(size) == 1) size = rep(size, n_labels)

			if(is.character(pch)) {
				gl = c(gl, list(
					textGrob(pch[index], x = grid_x, y = grid_y, gp = subset_gp(legend_gp, index))
				))
			} else {
				gl = c(gl, list(
					pointsGrob(x = grid_x, y = grid_y, pch = pch[index], gp = subset_gp(legend_gp, index), size = size)
				))
			}
		}
		if(any(c("lines", "l") %in% type)) {
			gl = c(gl, list(
				segmentsGrob(x0 = grid_x - grid_width*0.5, y0 = grid_y, 
					         x1 = grid_x + grid_width*0.5, y1 = grid_y,
					         gp = subset_gp(legend_gp, index))
			))
		}
	}

	class(gl) = "gList"
	gt = gTree(children = gl, cl = "legend_body", vp = viewport(width = legend_body_width, height = legend_body_height))
	attr(gt, "height") = legend_body_height
	attr(gt, "width") = legend_body_width
	return(gt)
}

vertical_continuous_legend_body = function(at, labels = at, col_fun,
	grid_height = unit(4, "mm"), grid_width = unit(4, "mm"),
	legend_height = NULL,
	labels_gp = gpar(fontsize = 10),
	border = NULL) {

	od = order(at)
	at = at[od]
	labels = labels[od]

	n_labels = length(labels)
	labels_max_width = max_text_width(labels, gp = labels_gp)

	labels_padding_left = unit(1, "mm")

	min_legend_height = length(at)*(grid_height)
	if(is.null(legend_height)) legend_height = min_legend_height
	if(convertHeight(legend_height, "mm", valueOnly = TRUE) < convertHeight(min_legend_height, "mm", valueOnly = TRUE)) {
		warning_wrap("`legend_height` you specified is too small, use the default minimal height.")
		legend_height = min_legend_height
	}

	segment_col = border
	if(is_diff_equal(at)) {
		at_diff_is_equal = TRUE
	} else {
		at_diff_is_equal = FALSE
		labels_padding_left = unit(4, "mm")
		# oborder = border
		# if(is.null(border)) segment_col = "black"
	}

	legend_body_width = grid_width + labels_padding_left + labels_max_width
	legend_body_height = legend_height
	legend_body_width = convertWidth(legend_body_width, "mm")
	legend_body_height = convertHeight(legend_body_height, "mm")

	gl = list()

	# labels
	labels_height = convertHeight(grobHeight(textGrob("foo", gp = labels_gp)), "mm")
	x = unit(rep(0, n_labels), "npc")
	offset = unit(0.5, "mm")
	k = length(at)
	ymin = offset
	ymax = legend_height-offset
	y = (at - at[1])/(at[k] - at[1])*(ymax - ymin) + ymin
	y = convertY(y, "mm")
	labels_x = grid_width + labels_padding_left
	labels_y = convertHeight(y, "mm")
	
	if(!at_diff_is_equal) {
		labels_height = do.call("unit.c", lapply(labels, 
			function(x) grobHeight(textGrob(x, gp = labels_gp)) + unit(2, "mm")))
		y_top = labels_y + labels_height*0.5
		y_bottom = labels_y - labels_height*0.5
		y_top = convertY(y_top, "mm", valueOnly = TRUE)
		y_bottom = convertY(y_bottom, "mm", valueOnly = TRUE)
		yrange = c(0, convertHeight(legend_body_height, "mm", valueOnly = TRUE))
		new_pos = smartAlign(y_bottom, y_top, yrange)
		y2 = (new_pos[, 1] + new_pos[, 2])/2
		y2 = unit(y2, "mm")
		labels_y = y2
	}

	if(all(abs(as.numeric(labels_y) - as.numeric(y)) < 1e-4)) {
		adjust_text_pos = FALSE
		labels_padding_left = unit(1, "mm")
		labels_x = grid_width + labels_padding_left
		legend_body_width = grid_width + labels_padding_left + labels_max_width
		legend_body_width = convertWidth(legend_body_width, "mm")
		# if(is.null(oborder)) segment_col = NULL
	} else {
		adjust_text_pos = TRUE
	}

	gl = c(gl, list(
		textGrob(labels, x = labels_x, y = labels_y, just = "left", gp = labels_gp)
	))
	
	## colors
	at2 = unlist(lapply(seq_len(n_labels - 1), function(i) {
		x = seq(at[i], at[i+1], length = round((at[i+1]-at[i])/(at[k]-at[1])*100))
		x = x[-length(x)]
	}))
	at2 = c(at2, at[length(at)])
	colors = col_fun(at2)
	x2 = unit(rep(0, length(colors)), "npc")
	y2 = seq(0, 1, length = length(colors)+1)
	y2 = y2[-length(y2)] * legend_body_height
	gl = c(gl, list(
		rectGrob(x2, rev(y2), width = grid_width, height = (unit(1, "npc"))*(1/length(colors)), just = c("left", "center"),
			gp = gpar(col = rev(colors), fill = rev(colors))),
		segmentsGrob(unit(0, "npc"), y, unit(0.8, "mm"), y, gp = gpar(col = ifelse(is.null(border), "white", border))),
		segmentsGrob(grid_width, y, grid_width - unit(0.8, "mm"), y, gp = gpar(col = ifelse(is.null(border), "white", border)))
	))

	if(adjust_text_pos) {
		segment_x0 = grid_width
		segment_y0 = y
		segment_x1 = grid_width + labels_padding_left*(1/3)
		segment_y1 = y
		gl = c(gl, list(
			segmentsGrob(segment_x0, segment_y0, segment_x1, segment_y1)
		))
		segment_x0 = grid_width + labels_padding_left - unit(0.5, "mm")
		segment_y0 = labels_y
		segment_x1 = grid_width + labels_padding_left*(2/3)
		segment_y1 = labels_y
		gl = c(gl, list(
			segmentsGrob(segment_x0, segment_y0, segment_x1, segment_y1)
		))
		segment_x0 = grid_width + labels_padding_left*(1/3)
		segment_y0 = y
		segment_x1 = grid_width + labels_padding_left*(2/3)
		segment_y1 = labels_y
		gl = c(gl, list(
			segmentsGrob(segment_x0, segment_y0, segment_x1, segment_y1)
		))
	}

	if(!is.null(border)) {
		gl = c(gl, list(
			rectGrob(width = grid_width, height = legend_height, x = unit(0, "npc"), just = "left", gp = gpar(col = border, fill = "transparent"))
		))
	}

	class(gl) = "gList"
	gt = gTree(children = gl, cl = "legend_body", vp = viewport(width = legend_body_width, height = legend_body_height))
	attr(gt, "height") = legend_body_height
	attr(gt, "width") = legend_body_width
	return(gt)
}

horizontal_continuous_legend_body = function(at, labels = at, col_fun,
	grid_height = unit(4, "mm"), grid_width = unit(4, "mm"),
	legend_width = NULL,
	labels_gp = gpar(fontsize = 10), labels_rot = 0,
	border = NULL, legend_extension = unit(0, "mm")) {
		
	od = order(at)
	at = at[od]
	labels = labels[od]
	k = length(at)

	labels_rot = labels_rot %% 360

	n_labels = length(labels)
	labels_width = do.call("unit.c", lapply(labels, function(x) {
			grobWidth(textGrob(x, gp = labels_gp, rot = labels_rot))
		}))
	labels_max_height = max(do.call("unit.c", lapply(labels, function(x) {
			grobHeight(textGrob(x, gp = labels_gp, rot = labels_rot))
		})))
	labels_max_height = convertHeight(labels_max_height, "mm")

	labels_padding_top = unit(1, "mm")

	min_legend_width = sum(labels_width)*1.5
	if(is.null(legend_width)) legend_width = min_legend_width

	segment_col = border

	legend_body_width = legend_width
	legend_body_height = grid_height + labels_padding_top + labels_max_height
	legend_body_width = convertWidth(legend_body_width, "mm")
	legend_body_height = convertHeight(legend_body_height, "mm")

	gl = list()

	# legend grid
	if(labels_rot != 0) {
		offset = convertHeight(grobHeight(textGrob("foo", gp = labels_gp))*0.5, "mm")
	} else {
		offset = unit(0.5, "mm")
	}
	xmin = offset
	xmax = legend_body_width - offset
	x = (at - at[1])/(at[k] - at[1])*(xmax - xmin)+ xmin
	x = convertX(x, "mm")
	labels_x = convertWidth(x, "mm")
	labels_y = legend_body_height - grid_height - labels_padding_top
	if(labels_rot == 0) {
		labels_just = "top"
	} else if(labels_rot > 0 & labels_rot < 180) {
		labels_just = "right"
	} else if(labels_rot > 180 & labels_rot < 360) {
		labels_just = "left"
	}
	# adjust the text position
	if(labels_rot == 0) {
		labels_width = do.call("unit.c", lapply(labels, 
			function(x) grobWidth(textGrob(x, gp = labels_gp))))
		x_right = labels_x + labels_width*0.5
		x_left = labels_x - labels_width*0.5
		x_right = convertX(x_right, "mm", valueOnly = TRUE)
		x_left = convertX(x_left, "mm", valueOnly = TRUE)
	} else {
		labels_height = do.call("unit.c", lapply(labels, 
			function(x) grobHeight(textGrob(x, gp = labels_gp))))
		x_right = labels_x + labels_height*0.5
		x_left = labels_x - labels_height*0.5
		x_right = convertX(x_right, "mm", valueOnly = TRUE)
		x_left = convertX(x_left, "mm", valueOnly = TRUE)
	}
	ext = convertX(legend_extension, "mm", valueOnly = TRUE)
	ext = max(convertWidth(grobWidth(textGrob(labels[1], gp = labels_gp))*0.5, "mm", valueOnly = TRUE), ext)
	if(labels_rot == 0) {
		xrange = c(0, ext + convertWidth(legend_body_width, "mm", valueOnly = TRUE) + convertWidth(grobWidth(textGrob(labels[n_labels], gp = labels_gp))*0.5, "mm", valueOnly = TRUE))
	} else {
		xrange = c(0, ext + convertWidth(legend_body_width, "mm", valueOnly = TRUE) + convertHeight(grobHeight(textGrob(labels[n_labels], gp = labels_gp))*0.5, "mm", valueOnly = TRUE))
	}

	new_pos = smartAlign(x_left + ext, x_right + ext, xrange) - ext
	x2 = (new_pos[, 1] + new_pos[, 2])/2
	x2 = unit(x2, "mm")
	labels_x = x2

	if(all(abs(as.numeric(labels_x) - as.numeric(x)) < 1e-4)) {
		adjust_text_pos = FALSE
	} else {
		# recalculate with adding 2mm padding between labels
		if(labels_rot == 0) {
			labels_width = do.call("unit.c", lapply(labels, 
			function(x) grobWidth(textGrob(x, gp = labels_gp)) + unit(2, "mm")))
			x_right = labels_x + labels_width*0.5
			x_left = labels_x - labels_width*0.5
			x_right = convertX(x_right, "mm", valueOnly = TRUE)
			x_left = convertX(x_left, "mm", valueOnly = TRUE)
			
			xrange = c(0, ext + convertWidth(legend_body_width, "mm", valueOnly = TRUE) + convertWidth(grobWidth(textGrob(labels[n_labels], gp = labels_gp))*0.5, "mm", valueOnly = TRUE) + 1)
			new_pos = smartAlign(x_left + ext, x_right + ext, xrange) - ext
			x2 = (new_pos[, 1] + new_pos[, 2])/2
			x2 = unit(x2, "mm")
			labels_x = x2
		}

		adjust_text_pos = TRUE
		labels_padding_top = unit(4, "mm")
		legend_body_height = grid_height + labels_padding_top + labels_max_height
		legend_body_height = convertHeight(legend_body_height, "mm")
		labels_y = legend_body_height - grid_height - labels_padding_top
		# if(is.null(segment_col)) segment_col = "black"
	}
	gl = c(gl, list(
		textGrob(labels, x = labels_x, y = labels_y, just = labels_just, gp = labels_gp, rot = labels_rot)
	))

	at2 = unlist(lapply(seq_len(n_labels - 1), function(i) {
		x = seq(at[i], at[i+1], length = round((at[i+1]-at[i])/(at[k]-at[1])*100))
		x = x[-length(x)]
	}))
	at2 = c(at2, at[length(at)])
	colors = col_fun(at2)
	y2 = unit(rep(1, length(colors)), "npc")
	x2 = seq(0, 1, length = length(colors)+1)
	x2 = x2[-length(x2)] * legend_body_width
	
	gl = c(gl, list(
		rectGrob(x2, y2, height = grid_height, width = (unit(1, "npc"))*(1/length(colors)), just = c("left", "top"),
			gp = gpar(col = colors, fill = colors)),
		segmentsGrob(x, legend_body_height - grid_height, x, legend_body_height - grid_height + unit(0.8, "mm"), gp = gpar(col = ifelse(is.null(border), "white", border))),
		segmentsGrob(x, legend_body_height - unit(0.8, "mm"), x, legend_body_height, gp = gpar(col = ifelse(is.null(border), "white", border)))
	))

	if(adjust_text_pos) {
		segment_x0 = x
		segment_y0 = legend_body_height - grid_height
		segment_x1 = x
		segment_y1 = legend_body_height - grid_height - labels_padding_top*(1/3)
		gl = c(gl, list(
			segmentsGrob(segment_x0, segment_y0, segment_x1, segment_y1)
		))
		segment_x0 = labels_x
		segment_y0 = legend_body_height - grid_height - labels_padding_top*(2/3)
		segment_x1 = labels_x
		segment_y1 = legend_body_height - grid_height - labels_padding_top + unit(0.5, "mm")
		gl = c(gl, list(
			segmentsGrob(segment_x0, segment_y0, segment_x1, segment_y1)
		))
		segment_x0 = x
		segment_y0 = legend_body_height - grid_height - labels_padding_top*(1/3)
		segment_x1 = labels_x
		segment_y1 = legend_body_height - grid_height - labels_padding_top*(2/3)
		gl = c(gl, list(
			segmentsGrob(segment_x0, segment_y0, segment_x1, segment_y1)
		))
	}

	if(!is.null(border)) {
		gl = c(gl, list(
			rectGrob(width = legend_width, height = grid_height, y = unit(1, "npc"), just = "top", gp = gpar(col = border, fill = "transparent"))
		))
	}

	class(gl) = "gList"
	gt = gTree(children = gl, cl = "legend_body", vp = viewport(width = legend_body_width, height = legend_body_height))
	attr(gt, "height") = legend_body_height
	attr(gt, "width") = legend_body_width
	return(gt)
}

# == title
# Pack Legends
#
# == param
# -... A list of objects returned by `Legend`.
# -gap Gap between two neighbouring legends. The value is a `grid::unit` object with length of one.
# -row_gap Horizontal gaps between legends.
# -column_gap Vertical gaps between legends.
# -direction The direction to arrange legends.
# -max_width The maximal width of the total packed legends. It only works for horizontal arrangement.
#           If the total width of the legends exceeds it, the legends will be arranged into multiple rows.
# -max_height Similar as ``max_width``, but for the vertical arrangment of legends.
# -list The list of legends can be specified as a list.
#
# == value
# A `Legends-class` object.
#
# == seealso
# https://jokergoo.github.io/ComplexHeatmap-reference/book/legends.html#a-list-of-legends
#
# == example
# require(circlize)
# col_fun = colorRamp2(c(0, 0.5, 1), c("blue", "white", "red"))
# lgd1 = Legend(at = 1:6, legend_gp = gpar(fill = 1:6), title = "legend1")
# lgd2 = Legend(col_fun = col_fun, title = "legend2", at = c(0, 0.25, 0.5, 0.75, 1))
# pd = packLegend(lgd1, lgd2)
# draw(pd, test = "two legends")
# pd = packLegend(lgd1, lgd2, direction = "horizontal")
# draw(pd, test = "two legends packed horizontally")
packLegend = function(...,gap = unit(2, "mm"), row_gap = unit(2, "mm"), column_gap = unit(2, "mm"),
	direction = c("vertical", "horizontal"),
	max_width = NULL, max_height = NULL, list = NULL) {

	dev.null()
	on.exit(dev.off2())

	if(!is.null(list)) {
		legend_list = list
	} else {
		legend_list = list(...)
	}
	if(length(legend_list) == 1) {
		return(legend_list[[1]])
	}

	legend_list = lapply(legend_list, function(x) {
		lgd = x@grob
		lgd$name = legend_grob_name()
		lgd
	})
	direction = match.arg(direction)
	if(direction == "vertical") {
		if(missing(row_gap)) {
			row_gap = gap
		}
	}
	if(direction == "horizontal") {
		if(missing(column_gap)) {
			column_gap = gap
		}
	}
	if(length(row_gap) != 1) {
		stop_wrap("Length of `row_gap` must be one.")
	}
	if(length(column_gap) != 1) {
		stop_wrap("Length of `column_gap` must be one.")
	}
    n_lgd = length(legend_list)
    if(direction == "vertical") {
	    lgd_height = do.call("unit.c", lapply(legend_list, grobHeight))

	    if(is.null(max_height)) {
	    	ind_list = list(1:n_lgd)
	    	nc = 1
	    } else {
	    	lgd_height_num = convertHeight(lgd_height, "mm", valueOnly = TRUE)
	    	max_height_num = convertHeight(max_height, "mm", valueOnly = TRUE)
	    	gap_num = convertHeight(column_gap, "mm", valueOnly = TRUE)

	    	if(n_lgd == 1 && max_height_num < lgd_height_num) {
	    		ind_list = list(1)
	    		nc = 1
	    	} else {
		    	ind_list = split_by_max(lgd_height_num, max_height_num, gap_num)
		    	nc = length(ind_list)
		    }
	    }

    	pack_width = NULL
    	pack_height = NULL
    	for(i in 1:nc) {
    		ind = ind_list[[i]]
    		pack_width = unit.c(pack_width, max(do.call("unit.c", lapply(legend_list[ ind_list[[i]] ], grobWidth))) + column_gap)

    		hu = do.call("unit.c", lapply(legend_list[ind], function(x) unit.c(grobHeight(x), row_gap)))
    		hu = hu[-length(hu)]
    		ph = sum(hu)
    		pack_height[i] = convertHeight(ph, "mm", valueOnly = TRUE)
    	}
    	pack_width[length(pack_width)] = pack_width[length(pack_width)] - column_gap
    	pack_width = convertWidth(pack_width, "mm")
    	pack_height = unit(max(pack_height), "mm")

    	## pack_width is the width for each column
    	## pack_height is the total height of the packed legends
    	gl = list()
    	for(i in 1:nc) {
    		ind = ind_list[[i]]
    		ni = length(ind)
    		legend_x = sum(pack_width[1:i]) - pack_width[i]  # most left side
    		legend_x = convertX(legend_x, "mm")
    		for(j in 1:ni) {
    			# the legend height in current column
    			current_legend_height = do.call("unit.c", lapply(legend_list[ind], function(x) grobHeight(x) + row_gap))
    			current_legend_height = convertHeight(current_legend_height, "mm")
    			legend_y = unit(1, "npc") - sum(current_legend_height[1:j]) + row_gap
	    		gl = c(gl, list(
	    			edit_vp_in_legend_grob(legend_list[[ ind[j] ]], x = legend_x, y = legend_y, valid.just = c(0, 0))
	    		))
	    	}
    	}
    } else {
    	lgd_width = do.call("unit.c", lapply(legend_list, grobWidth))

	    if(is.null(max_width)) {
	    	ind_list = list(1:n_lgd)
	    	nr = 1
	    } else {
	    	lgd_width_num = convertWidth(lgd_width, "mm", valueOnly = TRUE)
	    	max_width_num = convertWidth(max_width, "mm", valueOnly = TRUE)
	    	gap_num = convertWidth(column_gap, "mm", valueOnly = TRUE)

	    	if(n_lgd == 1 && max_width_num < lgd_width_num) {
	    		ind_list = list(1)
	    		nr = 1
	    	} else {
		    	ind_list = split_by_max(lgd_width_num, max_width_num, gap_num)
		    	nr = length(ind_list)
		    }
	    }

    	pack_width = NULL
    	pack_height = NULL
    	for(i in 1:nr) {
    		ind = ind_list[[i]]
    		pack_height = unit.c(pack_height, max(do.call("unit.c", lapply(legend_list[ind], function(x) grobHeight(x) + row_gap))))

    		hu = do.call("unit.c", lapply(legend_list[ind], function(x) unit.c(grobWidth(x), column_gap)))
    		hu = hu[-length(hu)]
    		ph = sum(hu)
    		pack_width[i] = convertWidth(ph, "mm", valueOnly = TRUE)
    	}
    	pack_height[length(pack_height)] = pack_height[length(pack_height)] - row_gap
    	pack_height = convertWidth(pack_height, "mm")
    	pack_width = unit(max(pack_width), "mm")

    	## pack_height is the height for each row
    	## pack_width is the total width of the packed legends

    	gl = list()
    	for(i in 1:nr) {
    		ind = ind_list[[i]]
    		ni = length(ind)
    		legend_y = unit(1, "npc") - sum(pack_height[1:i]) + pack_height[i]  # most bottom side
    		for(j in 1:ni) {
    			# the legend width in current row
    			current_legend_width = do.call("unit.c", lapply(legend_list[ind], function(x) grobWidth(x) + column_gap))
    			current_legend_width = convertWidth(current_legend_width, "mm")
    			legend_x = sum(current_legend_width[1:j]) - column_gap  # most right side
    			legend_x = convertX(legend_x, "mm")
	    		gl = c(gl, list(
	    			edit_vp_in_legend_grob(legend_list[[ ind[j] ]], x = legend_x, y = legend_y, valid.just = c(1, 1))
	    		))
	    	}
	    }
	    	
    }

    pack_legends_width = sum(pack_width)
    pack_legends_height = sum(pack_height)
    pack_legends_width = convertWidth(pack_legends_width, "mm")
    pack_legends_height = convertHeight(pack_legends_height, "mm")

    class(gl) = "gList"
	gt = gTree(children = gl, cl = "packed_legends", vp = viewport(width = pack_legends_width, height = pack_legends_height))
	attr(gt, "width") = pack_legends_width
	attr(gt, "height") = pack_legends_height

	object = new("Legends")
	object@grob = gt
	object@type = "packed_legends"
	object@n = n_lgd
	return(object)
}

# 
split_by_max = function(x, max, gap = 0) {
	x = x + gap
	ind = seq_along(x)
	ind_list = list()
	while(length(x)) {
		i = max(which(cumsum(x) < max))
		ind_list = c(ind_list, list(ind[1:i]))
		x = x[-(1:i)]
		ind = ind[-(1:i)]
	}
	ind_list
}

legend_grob_name = (function() {
	i = 1
	function() {
		txt = paste0("legend_grob_", i)
		i <<- i + 1
		return(txt)
	}
})()

edit_vp_in_legend_grob = function(gtree, ...) {
	if(is.null(gtree$vp)) {
		vp_param = list(...)
		nm = names(vp_param)
		if("valid.just" %in% nm) {
			valid.just = vp_param$valid.just
		} else {
			valid.just = NULL
		}
		vp_param = vp_param[names(vp_param) != "valid.just"]
		gtree$vp = do.call(viewport, vp_param)
		if(!is.null(valid.just)) {
			gtree$vp$valid.just = valid.just
		}
	} else {
		vp_param = list(...)
		nm = names(vp_param)
		if("just" %in% nm) {
			vp_param$valid.just = valid_just(vp_param$just)
		}
		
		for(nm in names(vp_param)) {
			gtree$vp[[nm]] = vp_param[[nm]]
		}
	}

	# gtree$vp$name = legend_vp_name()

	return(gtree)
}

valid_just = function(just) {
	if(length(just) == 1) {
		just = switch(just,
			"centre" = c("center", "center"),
			"center" = c("center", "center"),
			"left" = c("left", "center"),
			"right" = c("right", "center"),
			"top" = c("center", "top"),
			"bottom" = c("center", "bottom"),
			"top" = c("center", "top"),
			c("center", "center"))
	}
	if(length(just) != 2) {
		stop_wrap("`just` should be a single character or a vector of length 2.")
	}
	j = c("center" = 0.5, "left" = 0, "right" = 1, "top" = 1, "bottom" = 0)
	if(is.character(just)) {
		just = j[just]
	} else if(!is.numeric(just)) {
		stop_wrap("`just` can only be character or numeric.")
	}
	return(unname(just))
}

# == title
# Draw the Legends
#
# == param
# -object The `grid::grob` object returned by `Legend` or `packLegend`.
# -x The x position of the legends, measured in current viewport.
# -y The y position of the legends, measured in current viewport.
# -just Justification of the legends.
# -test Only used for testing.
#
# == details
# In the legend grob, there should always be a viewport attached which is like a wrapper of 
# all the graphic elements in a legend.
# If in the ``object``, there is already a viewport attached, it will modify the ``x``, ``y``
# and ``valid.just`` of the viewport. If there is not viewport attached, a viewport
# with specified ``x``, ``y`` and ``valid.just`` is created and attached.
#
# You can also directly use `grid::grid.draw` to draw the legend object, but you can
# only control the position of the legends by first creating a parent viewport and adjusting
# the position of the parent viewport.
#
# == example
# lgd = Legend(at = 1:4, title = "foo")
# draw(lgd, x = unit(0, "npc"), y = unit(0, "npc"), just = c("left", "bottom"))
#
# # and a similar version of grid.draw
# pushViewport(viewport(x = unit(0, "npc"), y = unit(0, "npc"), just = c("left", "bottom")))
# grid.draw(lgd)
# popViewport()
setMethod(f = "draw",
	signature = "Legends",
	definition = function(object, x = unit(0.5, "npc"), y = unit(0.5, "npc"), just = "centre", test = FALSE) {
	
	legend = object@grob
	legend = edit_vp_in_legend_grob(legend, x = x, y = y, valid.just = valid_just(just))

	if(is.character(test)) {
		test2 = TRUE
	} else {
		test2 = test
		test = ""
	}
	if(test2) {
        grid.newpage()
        # rect_grob = rectGrob(gp = gpar(col = "red", lty = 2, fill = "transparent"))
        # legend$children[[rect_grob$name]] = rect_grob
        # legend$childrenOrder = c(legend$childrenOrder, rect_grob$name)
    }
	grid.draw(legend)
	if(test2) {
		grid.text(test, x = 0.5, y = unit(1, "npc") - unit(1, "cm"))
	}
})

# == title
# Draw the Legends
#
# == param
# -x The `grid::grob` object returned by `Legend` or `packLegend`.
# -recording Pass to `grid::grid.draw`.
#
# == details
# This function is actually an S3 method of the ``Legends`` class for the `grid::grid.draw`
# general method. It applies `grid::grid.draw` on the ``grob`` slot of the object.
#
# == example
# lgd = Legend(at = 1:4, title = "foo")
# pushViewport(viewport(x = unit(0, "npc"), y = unit(0, "npc"), just = c("left", "bottom")))
# grid.draw(lgd)
# popViewport()
grid.draw.Legends = function(x, recording = TRUE) {
	grid.draw(x@grob, recording =  recording)
}

# == title
# Grob width for legend_body
#
# == param
# -x A legend_body object.
#
widthDetails.legend_body = function(x) {
	attr(x, "width")
}

# == title
# Grob height for legend_body
#
# == param
# -x A legend_body object.
#
heightDetails.legend_body = function(x) {
	attr(x, "height")
}

# == title
# Grob width for packed_legends
#
# == param
# -x A legend object.
#
widthDetails.legend = function(x) {
	attr(x, "width")
}

# == title
# Grob height for packed_legends
#
# == param
# -x A legend object.
#
heightDetails.legend = function(x) {
	attr(x, "height")
}

# == title
# Grob width for packed_legends
#
# == param
# -x A packed_legends object.
#
widthDetails.packed_legends = function(x) {
	attr(x, "width")
}

# == title
# Grob height for packed_legends
#
# == param
# -x A packed_legends object.
#
heightDetails.packed_legends = function(x) {
	attr(x, "height")
}


# assume x is ordered
is_diff_equal = function(x) {
	all(abs(diff(diff(x)))/mean(diff(x)) < 1e-4)
}
