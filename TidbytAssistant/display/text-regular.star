load("render.star", "render")

def main(config):
	return render.Root(          
        child=render.WrappedText(
            content="%DISPLAY_TEXT%",
            font="%DISPLAY_FONT%",
        ),
	)