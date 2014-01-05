class MapHandler

  @handler = null

  constructor: ->
    @handler = Gmaps.build("Google")
    @handler.buildMap
      provider: {}
      internal:
        id: "map"
    , ->
      markers = @handler.addMarkers([
        lat: 0
        lng: 0
        picture:
          url: "https://addons.cdn.mozilla.net/img/uploads/addon_icons/13/13028-64.png"
          width: 36
          height: 36
      ])
      @handler.bounds.extendWith markers
      @handler.fitMapToBounds()

  setMarkers: (markers_) =>
    @handler = Gmaps.build("Google")
    @handler.buildMap
      provider: {}
      internal:
        id: "map"
    , ->
      markers = @handler.addMarkers(markers_)
      @handler.bounds.extendWith markers
      @handler.fitMapToBounds()

@maphandler = new MapHandler('')
@maphandler.setMarkers(markers)