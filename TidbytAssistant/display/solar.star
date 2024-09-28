"""
Applet: Solar Data from Home Assistant
Summary: Displays production and consumption data from Home Assistant
Description: Single screen with animations showing production, consumption and power sent to grid
Author: tavdog, marcbaier, motoridersd, daniel-sabourin
"""

load("encoding/base64.star", "base64")
load("humanize.star", "humanize")
load("render.star", "render")
load("schema.star", "schema")

GRAY = "#777777"
RED = "#AA0000"  # very bright at FF, dim a little to AA
GREEN = "#00FF00"

SOLAR = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACeklEQVQ4jY2TT0hUQRzHvzPz3u7bfe6umroQuKwmhCQbLNIfyDCIkoiog9XJolsdOglBVOKlgrqI9xAvhUJEEIKXwjpFqJERmbCRGKbRqrv73vO9+RPz8BCxoj+YP78fzGe+850ZKKV218YORPQoJnI3/82J7naMyYO24OQiq8Sfcds9ZpDylCQ1V2gpGNkdQMfEkaSEtwCgEQpLboV32r1zyzsD3rRY0qvtU0CRKDWmS0FZgTBy14irDdL//PO7mRXeEWyUTcKoMuIx7q2uWlZTkwfga9dy7ujAACRe5eoE6CJ3lA0JGVWsGZenf9JrHVYKQMpM1sR5qWSDkBSzrKhwXF0/NJX+1Bd6QNkZ5iNPDPo4apOMSMrTGO+I0CjD4uFGNS1cDzQSgf+nCGpG4BeL0DXpOQ87Z54YjMkXuDA7b8TwDWdnl5ihxtA751MAt861WXsguaCmCe44kEEAFovBX1uH4iKdiMt+nPpY0een1tpo6M1WHppYKBRGJr8HLePz3nG56YNXKojU18Fb/gUr3QSlUJJK5F/fyC/877FWoB/KvZMZYx/1PVcKDu664BUHNBqFt/JbK0mIsvey2iWFgNbW1h+Ukqc9zcYXCAkzkQg9IIxBeB4U55CB3949/L6rKkAHY+z++Vx9uqExsWImE+Hu+omYtbWQnINZFiAwui0gk8kUCVFDV9vNBV6uAIQiWNcmcqggCJUIx812P3p7vSogdJSQ4f0N0b3gQRDmjEH6PphtQ5TLW5+OPdgWkM1mPZOSwUv5hoKWbCaToQI9p5YVAsFoqnvow+2qgC3IaE9bbDMeYQ4ICRdq+caWijCkvHNiEAYA/AVIsU5KC49FbgAAAABJRU5ErkJggg==
""")
HOUSE = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACxUlEQVQ4jXWSbUhTYRTHz3nuXq66efNlmzXFzKb5mltjM6sPBZVBZvq1PvWlooImFEooWSASlWDoPkQfIihKkSilUkHKXnyh8qXSwlq+Tm2WuJpe3e4Td+S1tTxwuIff+f8fzvPcg5RSWC2s0THXkCDpmHaeWE0j+x9ERLREaW+WJhsPIQJYNDFct2vKlpyaXkXkjEAFIMNDn0o8Hs9o0ASIyFijtHfLkrIKGlhKRFbIAz3Z19lx0HbGnGE2yyfHx+DKhVKLy+nsJv+Y5dZo3YPy5M2FDWGEFNXWgpgNoQzaM7Ozv7Y2uwWfD8JUalBxnEv0kL/MbE50zONyQ+a++nAlnrXb4UX7M3+KdX24Ao8CG9FUWfF9YnQEZicnDX7jnyuodmjWPn+0dbdwLK+AfnaM0ObmNrol3eRPsRaZ2BM1lg2GOY7j9ohegogR2yO1LSUb03Oa9JFYXFMDqjA1xMbFgixE4U+xFpnYEzXndetVJjlbhogcpqm5zooUU+aT+Bi2+GoVKJVK6U0WF3n/V6FYYTzPQ2WRDfYOTy6cG3jbh4msauc8CqcuXb+RF6IgshHHkCQ2pGSAjwJ8HOgP+FNqLtp78bStMQRJtWxo3t2GiNNKlt3ffKca8nUOSdjyPgN+LCxBltArsfHZJXCZjsAE7ymnlPYsL9IXo9EoPK1jICqMkcTMPAHQbILx9MMSmx4bAZ3PHbSJyV1dnQE7sRyhag7Sdh1YGX+gD352NAUdEBBegULr4C8ALcCCew7ab9VI/ZkpJ6Tp1qwcoDcwlzXxmHC/8TajXYYEITdVBXUugG3WJHjd+1IyrAsH6B/8QDTxWKo3MA5ZollWmHtcmfDm3jsKroSgaV71PISE/PYApgcgVlAVPrbzDoxLIb2xKTJYmNbFK92hPqNeLr1F3xT18qwA+tTFgKtSoPTbzNjo2IAXfgP14QtOLPDWZgAAAABJRU5ErkJggg==
""")
GRID = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAQCAYAAAAiYZ4HAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGeGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDIgNzkuMTY0NDYwLCAyMDIwLzA1LzEyLTE2OjA0OjE3ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIiB4bWxuczpwaG90b3Nob3A9Imh0dHA6Ly9ucy5hZG9iZS5jb20vcGhvdG9zaG9wLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIxLjIgKE1hY2ludG9zaCkiIHhtcDpDcmVhdGVEYXRlPSIyMDIzLTAyLTEzVDE1OjM5OjQwKzAxOjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMy0wMi0xN1QwODozODoxNCswMTowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wMi0xN1QwODozODoxNCswMTowMCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoxMTQ4NjFkYi1mMDk2LTQ0ODUtYjMyNy1jN2Y3ZWNlYjRiYTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QTY4NjlFRkFBM0M5MTFFREI1RkZGNzIwOTI2RUIzNzEiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpBNjg2OUVGQUEzQzkxMUVEQjVGRkY3MjA5MjZFQjM3MSIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOkE2ODY5RUY3QTNDOTExRURCNUZGRjcyMDkyNkVCMzcxIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOkE2ODY5RUY4QTNDOTExRURCNUZGRjcyMDkyNkVCMzcxIi8+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjExNDg2MWRiLWYwOTYtNDQ4NS1iMzI3LWM3ZjdlY2ViNGJhMyIgc3RFdnQ6d2hlbj0iMjAyMy0wMi0xN1QwODozODoxNCswMTowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIxLjIgKE1hY2ludG9zaCkiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDxwaG90b3Nob3A6RG9jdW1lbnRBbmNlc3RvcnM+IDxyZGY6QmFnPiA8cmRmOmxpPnhtcC5kaWQ6QTY4NjlFRkFBM0M5MTFFREI1RkZGNzIwOTI2RUIzNzE8L3JkZjpsaT4gPC9yZGY6QmFnPiA8L3Bob3Rvc2hvcDpEb2N1bWVudEFuY2VzdG9ycz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz648dNvAAACH0lEQVQokZVRX0hTcRT+zu9uzt27u7nhZBKUexECZ+UQxYKyXrICCVkkZVAQ4V5Det2DIFG9VAzyoaA/oxgR9RCGUJrEnPYHC0REECUh0hzqbl7v3e7pYWzMvfU9nnO+73zfOcTM+B/YAICIUCSGBh7F13//WgYAX11g749bl6PlBGJmEBE674xf0jbM45nVxfCFK82vAeDZw+/dXn/wi+Kxv/9w/ehjZoYoqI4OBeqkc6dOq+uWZW2BqQZMNZZlbXWdcWfq/SISGhgdKlnyqKLh54qxPDu7vS67qCmZSE0BgOxyNr15tfHW5ZEcHlU0AACYGX3vVs8zM5gZjf3D6dh0ejA2nR5s7B9OF+vFGRsAbGadayduj90TEimGaelgqgEAw8xvd90du7+tWbJ7f/g5gEKGxfTk2aZmh9xxpHpGUSmUTKRyyUQqp6iiub3DuXAw7LSWUp+7SxncHlGb+vh3Td9BPSyaj1xszwJA8unM/MsX2UCVAztuj6gtEQItrePJk644AOzpS8fAVAsAmT+rIytPrsYAIDKSjZb+UI5DN+Jf82b+EwBIdunwt5vRlvK+2PVFImib+kRPb5vU09smaZv6BBGBiHYTyouy4vAyI8OMjKw4vOViuzYU7+3zq0EWPMeC53x+NVhp2YYK5I38pGDRCQCmbk5V9omZca31wBgA5ESVYlQr+5AztwpydrVK15ZslqEBwIPpmWP/AP8h6z0LPIXhAAAAAElFTkSuQmCC
""")

GREEN_ANIM = base64.decode("""
R0lGODlhBwAQAKIEAEhsBIXBDb/iQElsBP///wAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh/wtYTVAgRGF0YVhNUDw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDYuMC1jMDAyIDc5LjE2NDQ2MCwgMjAyMC8wNS8xMi0xNjowNDoxNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo2ZjcyNmRlMi05NTNmLTQwYmEtOTA3Yy0yNmVlMDg3ZTMxOWEiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MTAxQzdERTdBMjQ1MTFFREI1RkZGNzIwOTI2RUIzNzEiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MTAxQzdERTZBMjQ1MTFFREI1RkZGNzIwOTI2RUIzNzEiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIxLjIgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpiZmU5YTI5MS02MjBhLTQ3NTItOWRhZS1lOWU2MGM1YWViOWUiIHN0UmVmOmRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDo2ZWYxNzU1Zi0zYzE1LWY5NGMtODkzNC1jN2FjYjhjZTVhMDEiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4B//79/Pv6+fj39vX08/Lx8O/u7ezr6uno5+bl5OPi4eDf3t3c29rZ2NfW1dTT0tHQz87NzMvKycjHxsXEw8LBwL++vby7urm4t7a1tLOysbCvrq2sq6qpqKempaSjoqGgn56dnJuamZiXlpWUk5KRkI+OjYyLiomIh4aFhIOCgYB/fn18e3p5eHd2dXRzcnFwb25tbGtqaWhnZmVkY2JhYF9eXVxbWllYV1ZVVFNSUVBPTk1MS0pJSEdGRURDQkFAPz49PDs6OTg3NjU0MzIxMC8uLSwrKikoJyYlJCMiISAfHh0cGxoZGBcWFRQTEhEQDw4NDAsKCQgHBgUEAwIBAAAh+QQFAAAEACwAAAAABwAQAAADDki63P4wskEAoVTqzWMCACH5BAUAAAQALAAAAAABAAEAAAMCSAkAIfkEBQAABAAsAAAHAAEAAQAAAwIoCQAh+QQFAAAEACwAAAAAAQABAAADAkgJACH5BAUAAAQALAAABwABAAEAAAMCOAkAIfkEBQAABAAsAAAAAAEAAQAAAwJICQAh+QQFAAAEACwCAAcAAQABAAADAhgJACH5BAUAAAQALAAAAAABAAEAAAMCSAkAIfkEBQAABAAsAgAHAAEAAQAAAwIICQAh+QQFAAAEACwAAAAAAQABAAADAkgJACH5BAUAAAQALAIABwADAAEAAAMDOBQJACH5BAUAAAQALAAAAAABAAEAAAMCSAkAIfkEBQAABAAsAgAHAAMAAQAAAwMINAkAIfkEBQAABAAsAAAAAAEAAQAAAwJICQAh+QQFAAAEACwGAAcAAQABAAADAhgJACH5BAUAAAQALAAAAAABAAEAAAMCSAkAOw==
""")
RED_ANIM = base64.decode("""
R0lGODlhBwAQAJECAP8AAIUJCf///wAAACH/C05FVFNDQVBFMi4wAwEAAAAh/wtYTVAgRGF0YVhNUDw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDYuMC1jMDAyIDc5LjE2NDQ2MCwgMjAyMC8wNS8xMi0xNjowNDoxNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo2ZjcyNmRlMi05NTNmLTQwYmEtOTA3Yy0yNmVlMDg3ZTMxOWEiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QTY4NjlFRjJBM0M5MTFFREI1RkZGNzIwOTI2RUIzNzEiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QTY4NjlFRjFBM0M5MTFFREI1RkZGNzIwOTI2RUIzNzEiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIxLjIgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpiNDE5ZDEyZC1jYzY3LTQwYmQtODY5Mi0wMGY1MzMwZmI5N2YiIHN0UmVmOmRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDplMGFkZGY2Zi1jZGMzLWI3NDQtYTRkNC02MGYyMTg4NjhjOGUiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4B//79/Pv6+fj39vX08/Lx8O/u7ezr6uno5+bl5OPi4eDf3t3c29rZ2NfW1dTT0tHQz87NzMvKycjHxsXEw8LBwL++vby7urm4t7a1tLOysbCvrq2sq6qpqKempaSjoqGgn56dnJuamZiXlpWUk5KRkI+OjYyLiomIh4aFhIOCgYB/fn18e3p5eHd2dXRzcnFwb25tbGtqaWhnZmVkY2JhYF9eXVxbWllYV1ZVVFNSUVBPTk1MS0pJSEdGRURDQkFAPz49PDs6OTg3NjU0MzIxMC8uLSwrKikoJyYlJCMiISAfHh0cGxoZGBcWFRQTEhEQDw4NDAsKCQgHBgUEAwIBAAAh+QQFAAACACwAAAAABwAQAAACDJSPqcuNIaB0tFpXAAAh+QQFAAACACwAAAAAAQABAAACAlQBACH5BAUAAAIALAYABwABAAEAAAICRAEAIfkEBQAAAgAsAAAAAAEAAQAAAgJUAQAh+QQFAAACACwGAAcAAQABAAACAkwBACH5BAUAAAIALAAAAAABAAEAAAICVAEAIfkEBQAAAgAsBAAHAAEAAQAAAgJEAQAh+QQFAAACACwAAAAAAQABAAACAlQBACH5BAUAAAIALAQABwABAAEAAAICTAEAIfkEBQAAAgAsAAAAAAEAAQAAAgJUAQAh+QQFAAACACwCAAcAAQABAAACAkQBACH5BAUAAAIALAAAAAABAAEAAAICVAEAIfkEBQAAAgAsAgAHAAEAAQAAAgJMAQAh+QQFAAACACwAAAAAAQABAAACAlQBACH5BAUAAAIALAAABwABAAEAAAICRAEAIfkEBQAAAgAsAAAAAAEAAQAAAgJUAQA7
""")
EMPTY = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAcAAAAQCAYAAADagWXwAAAACXBIWXMAAAsTAAALEwEAmpwYAAAKn2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDIgNzkuMTY0NDYwLCAyMDIwLzA1LzEyLTE2OjA0OjE3ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIiB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjEuMiAoTWFjaW50b3NoKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjMtMDItMTNUMTQ6MTc6NTcrMDE6MDAiIHhtcDpNb2RpZnlEYXRlPSIyMDIzLTAyLTE2VDE2OjM3OjM5KzAxOjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDIzLTAyLTE2VDE2OjM3OjM5KzAxOjAwIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgcGhvdG9zaG9wOklDQ1Byb2ZpbGU9InNSR0IgSUVDNjE5NjYtMi4xIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjQ1OWVjNDYzLThiMzYtNDc2ZC05YjY2LTQ2ZjM2NmIzNTZmMCIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOmQ2ZGY2MGY5LWViZTItY2Y0OS1hMDI5LTkwZjE4YzQ4OGUyNyIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjZmNzI2ZGUyLTk1M2YtNDBiYS05MDdjLTI2ZWUwODdlMzE5YSIgdGlmZjpPcmllbnRhdGlvbj0iMSIgdGlmZjpYUmVzb2x1dGlvbj0iNzIwMDAwLzEwMDAwIiB0aWZmOllSZXNvbHV0aW9uPSI3MjAwMDAvMTAwMDAiIHRpZmY6UmVzb2x1dGlvblVuaXQ9IjIiIGV4aWY6Q29sb3JTcGFjZT0iMSIgZXhpZjpQaXhlbFhEaW1lbnNpb249IjciIGV4aWY6UGl4ZWxZRGltZW5zaW9uPSIxNiI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6NmY3MjZkZTItOTUzZi00MGJhLTkwN2MtMjZlZTA4N2UzMTlhIiBzdEV2dDp3aGVuPSIyMDIzLTAyLTEzVDE0OjE3OjU3KzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjEuMiAoTWFjaW50b3NoKSIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6Y2NhNWUzNTYtOGMwNC00NDdmLWI5M2EtYmI0NGQ4NjJmNTBlIiBzdEV2dDp3aGVuPSIyMDIzLTAyLTEzVDE0OjQ0OjIzKzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjEuMiAoTWFjaW50b3NoKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6M2E4ODlkOTMtYzIzYi00OWE5LWFiMzAtZjExNzc1ODMyYTUxIiBzdEV2dDp3aGVuPSIyMDIzLTAyLTE2VDE2OjM3OjM5KzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjEuMiAoTWFjaW50b3NoKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY29udmVydGVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJmcm9tIGFwcGxpY2F0aW9uL3ZuZC5hZG9iZS5waG90b3Nob3AgdG8gaW1hZ2UvcG5nIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJkZXJpdmVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJjb252ZXJ0ZWQgZnJvbSBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wIHRvIGltYWdlL3BuZyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6NDU5ZWM0NjMtOGIzNi00NzZkLTliNjYtNDZmMzY2YjM1NmYwIiBzdEV2dDp3aGVuPSIyMDIzLTAyLTE2VDE2OjM3OjM5KzAxOjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjEuMiAoTWFjaW50b3NoKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6M2E4ODlkOTMtYzIzYi00OWE5LWFiMzAtZjExNzc1ODMyYTUxIiBzdFJlZjpkb2N1bWVudElEPSJhZG9iZTpkb2NpZDpwaG90b3Nob3A6ZTBhZGRmNmYtY2RjMy1iNzQ0LWE0ZDQtNjBmMjE4ODY4YzhlIiBzdFJlZjpvcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6NmY3MjZkZTItOTUzZi00MGJhLTkwN2MtMjZlZTA4N2UzMTlhIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+55hYNAAAABdJREFUGJVj/P//PwMuwIRTZlRykEoCAIOxAx1aidCyAAAAAElFTkSuQmCC
""")

def w2kw(w):
    return float(humanize.float("#.#", int(w) / 1000.0))

def display(string):
    return humanize.float("#.#", string)

def main(config):
    generation_kw = w2kw(config.str("generation", 0))
    consumption_kw = w2kw(config.str("consumption", 0))
    grid_rate_kw = generation_kw - consumption_kw

    print("Generation: %s kW" % generation_kw)
    print("Consumption: %s kW" % consumption_kw)
    print("Grid Rate: %s kW" % grid_rate_kw)

    if generation_kw > 0:
        solar_anim = GREEN_ANIM
        solar_color = GREEN
    else:
        solar_anim = EMPTY
        solar_color = GRAY

    if grid_rate_kw > 0:
        grid_anim = GREEN_ANIM
        grid_color = GREEN
    elif grid_rate_kw < 0:
        grid_anim = RED_ANIM
        grid_color = RED
    else:
        grid_anim = EMPTY
        grid_color = GRAY

    main_frame = render.Row(
        children = [
            render.Box(
                height = 32,
                width = 15,
                child = render.Column(
                    expanded = True,
                    cross_align = "center",
                    main_align = "space_evenly",
                    children = [
                        render.Image(src = SOLAR, height = 15),
                        render.Padding(
                            pad = (1, 0, 0, 0),
                            child = render.Column(
                                cross_align = "center",
                                children = [
                                    render.Text(display(abs(generation_kw)), color = solar_color),
                                    render.Text("kW", color = GRAY),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
            render.Box(
                height = 32,
                width = 10,
                child = render.Column(
                    expanded = True,
                    cross_align = "center",
                    main_align = "start",
                    children = [
                        render.Image(src = solar_anim),
                    ],
                ),
            ),
            render.Box(
                height = 32,
                width = 15,
                child = render.Column(
                    expanded = True,
                    cross_align = "center",
                    main_align = "space_evenly",
                    children = [
                        render.Image(src = HOUSE, height = 15),
                        render.Padding(
                            pad = (0, 0, 0, 0),
                            child =
                                render.Column(
                                    cross_align = "center",
                                    children = [
                                        render.Text(display(consumption_kw)),
                                        render.Text("kW", color = GRAY),
                                    ],
                                ),
                        ),
                    ],
                ),
            ),
            render.Box(
                height = 32,
                width = 10,
                child = render.Column(
                    expanded = True,
                    cross_align = "center",
                    main_align = "start",
                    children = [
                        render.Image(src = grid_anim),
                    ],
                ),
            ),
            render.Box(
                height = 32,
                width = 14,
                child = render.Column(
                    expanded = True,
                    cross_align = "center",
                    main_align = "space_evenly",
                    children = [
                        render.Image(src = GRID),
                        render.Padding(
                            pad = (0, 0, 0, 0),
                            child = render.Column(
                                cross_align = "center",
                                children = [
                                    render.Text(display(abs(grid_rate_kw)), color = grid_color),
                                    render.Text("kW", color = GRAY),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        ],
    )

    return render.Root(main_frame)

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "generation",
                name = "Generation",
                desc = "Current Power Generation (W)",
                icon = "solarPanel",
            ),
            schema.Text(
                id = "consumption",
                name = "Consumption",
                icon = "plug",
                desc = "Current Power Consumption (W)",
            ),
        ],
    )
