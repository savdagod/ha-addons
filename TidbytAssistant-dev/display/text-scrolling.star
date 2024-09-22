load("render.star", "render")

def main(config):
        content = config.get("content")
        font = config.get("font")
        color = config.get("color")
	return render.Root(          
		child = render.Box(
            render.Row(
                expanded=True, # Use as much horizontal space as possible
                main_align="space_evenly", # Controls horizontal alignment
                cross_align="center", # Controls vertical alignment
                children = [
                    render.Marquee(
                        width=50,
                        offset_start=49,
                        align="center",
                        child=render.Text(
                            content=content,
                            font=font,
                            color=color,
                        ),
                    ),
                ],
            ),
		),
	)
