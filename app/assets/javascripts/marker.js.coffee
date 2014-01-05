class RichMarkerBuilder extends Gmaps.Google.Builders.Marker

  create_marker: ->
    options = _.extend @marker_options(), @rich_marker_options()
    @serviceObject = new RichMarker options

  rich_marker_options: ->
    marker = document.createElement("div")
    style = 'marker_default'
    time = parseFloat(@args.title)
    if time <= 0.3
      style = 'marker_green'
    else if time >= 0.3 && time <= 0.69
      style = 'marker_orange'
    else if time >= 0.7 && time <= 1.0
      style = 'marker_red'
    else
      style = 'marker_red'
    marker.setAttribute 'class', style
    marker.innerHTML = @args.title
    { content: marker }

@buildMap = (markers) ->
  handler = Gmaps.build 'Google', { builders: { Marker: RichMarkerBuilder} }
  handler.buildMap { provider: {}, internal: {id: 'map'} }, ->
    markers = handler.addMarkers(markers)
    handler.bounds.extendWith(markers)
    handler.fitMapToBounds()