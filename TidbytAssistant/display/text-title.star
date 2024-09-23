load("render.star", "render")
default_title = "TITLE"
default_font = "6x13"
default_color = "#00f"

def main(config):
	content = config.get("content")
	font = config.get("font")
	color = config.get("color")
	title = config.get("title",default_title)
	titlefont = config.get("titlefont",default_font)
	titlecolor = config.get("titlecolor",default_color)
	return render.Root(
		child = render.Column(
		expanded=True,
		main_align="center",
		cross_align="center",
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
