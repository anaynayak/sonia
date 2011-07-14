var Cctray = Class.create(Widget, {
  initialize: function($super, widget_id, config) {
    this.messages = [];
    this.map = {'Success' : 'green',
                'Failure' : 'red',
                'Unknown' : 'grey',
                'Exception' : 'yellow',
        }
    return($super(widget_id, config));
  },

  handlePayload: function(payload) {
    this.messages = payload.items;
  },

  build: function() {
    this.contentContainer = this.buildContent();
    this.headerContainer  = this.buildHeader();
    this.iconContainer    = this.buildWidgetIcon();

    this.container.insert(this.headerContainer);
    this.container.insert(this.iconContainer);
    this.container.insert(this.contentContainer);

    this.makeDraggable();
  },

  update: function() {
    this.contentContainer.childElements().invoke('remove');
    this.messages.each(function(message){
      var status = new Element('div', {'style': "width:50px; height:50px; float:left; margin:10px; background-color: " + this.map[message.build_status]}).update("&nbsp;")
      var link = new Element('div')
      link.insert(new Element('div', {'style': "font-weight:bold; margin:5px"}).update(message.name))
      link.insert(new Element('div', {'style': "margin:5px; "}).update(message.time))
      this.contentContainer.insert(status);
      this.contentContainer.insert(link);
      this.contentContainer.insert(new Element('hr' ));
    }.bind(this));
  },

  buildWidgetIcon: function() {
    return(new Element("img", {src: "/images/cctray/icon.png", width: 32, height: 32, 'class': 'rss icon'}));
  },

  buildHeader: function() {
    return(new Element("h2", { 'class': 'handle' }).update(this.title));
  },

  buildContent: function() {
    return(new Element("div", { 'class': "content" }));
  },
});
