load("render.star", "render")

def main(config):
	content = config.get("content")
	title = config.get("title")
	font = config.get("font")
	titlefont = config.get("titlefont")
	color = config.get("color")
	titlecolor = config.get("titlecolor")
    return render.Root(
        child = render.Column(
            expanded = True,
            main_align = "center",
            cross_align = "center",
            children = [
                render.Text(
					content=title, 
					font=titlefont,
					color=titlecolor,
				),
				render.Marquee(
					width=60,
					offset_start=59,
					child=render.Text(
						content=content,
						font=font,
						color=color,
					),
				),
            ],
        ),
    )
