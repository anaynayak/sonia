var Cctray = Class.create(Widget, {
  initialize: function($super, widget_id, config) {
    this.messages = [];
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
      var link = new Element('a', { 'style': "background-image=/images/cctray/" + message.build_status + ".png", href: message.url }).update(message.name + " at " + message.time)
      this.contentContainer.insert(link);
      this.contentContainer.insert(new Element('hr' ));
    }.bind(this));
  },

  buildWidgetIcon: function() {
    return(new Element("img", {src: "/images/rss/rss.png", width: 32, height: 32, 'class': 'rss icon'}));
  },

  buildHeader: function() {
    return(new Element("h2", { 'class': 'handle' }).update(this.title));
  },

  buildContent: function() {
    return(new Element("div", { 'class': "content" }));
  },
});
