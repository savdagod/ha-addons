load("render.star", "render")

def main(config):
    content = config.get("content")
    font = config.get("font")
    color = config.get("color")
    return render.Root(
        child = render.WrappedText(
            content = content,
            font = font,
            color = color,
        ),
    )
