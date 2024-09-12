load("render.star", "render")

def main(config):
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
                        child=render.Text(
                            content="%DISPLAY_TEXT%",
                            font="6x13",
                        ),
                    ),
                ],
            ),
		),
	)