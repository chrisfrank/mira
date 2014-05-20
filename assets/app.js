// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  app.AppController = (function() {
    function AppController() {
      document.dispatchEvent(new CustomEvent('app:starting'));
      app.prompt = "Did you need to be in New York City today?";
      app.views = {
        top: new app.TopView(document.getElementById('top')),
        prompt: new app.PromptView(document.getElementById('prompt')),
        scroller: new app.ScrollView(document.getElementById('list')),
        input: new app.InputView(document.getElementById('input')),
        stats: new app.StatsView(document.getElementById('stats')),
        history: new app.HistoryView(document.getElementById('history'))
      };
      app.entries = new app.EntriesCollection();
      this.listen();
      document.dispatchEvent(new CustomEvent('app:loaded'));
    }

    AppController.prototype.listen = function() {
      return document.addEventListener('entry:create', function(e) {
        return app.entries.add(new app.Entry({
          answer: e.detail.answer
        }));
      });
    };

    return AppController;

  })();

  document.addEventListener('DOMContentLoaded', function() {
    return app.controller = new app.AppController;
  });

  app.EntriesCollection = (function() {
    function EntriesCollection() {
      this.restore();
    }

    EntriesCollection.prototype.restore = function() {
      this.records = [];
      if (localStorage["mira:entries"] != null) {
        this.records = JSON.parse(localStorage["mira:entries"]).map(function(entry) {
          return new app.Entry(entry);
        });
      }
      this.broadcastChange();
      return this.records;
    };

    EntriesCollection.prototype.save = function() {
      localStorage["mira:entries"] = JSON.stringify(this.records);
      this.broadcastChange();
      return this.records;
    };

    EntriesCollection.prototype.add = function(entry) {
      this.records.push(entry);
      return this.save();
    };

    EntriesCollection.prototype.getRecords = function() {
      return this.records.slice(0);
    };

    EntriesCollection.prototype.reset = function() {
      this.records = [];
      document.dispatchEvent(new CustomEvent('entries:reset'));
      return this.save();
    };

    EntriesCollection.prototype.seed = function() {
      var i, _results;
      i = 0;
      _results = [];
      while (i < 20) {
        this.add(new app.Entry({
          answer: i % 2,
          date: new Date(1987, 0, i)
        }));
        _results.push(i += 1);
      }
      return _results;
    };

    EntriesCollection.prototype.broadcastChange = function() {
      return document.dispatchEvent(new CustomEvent('entries:changed', {
        detail: {
          collection: this
        }
      }));
    };

    return EntriesCollection;

  })();

  document.addEventListener('app:started', function(e) {});

  app.Entry = (function() {
    function Entry(args) {
      args || (args = {});
      args.date || (args.date = Date.now());
      if (!(args.answer === 1 || args.answer === 0)) {
        throw "Can't create entry without answer";
      }
      this.setDate(args.date);
      this.setAnswer(args.answer);
    }

    Entry.prototype.getDate = function() {
      return this.date;
    };

    Entry.prototype.setDate = function(date) {
      return this.date = date;
    };

    Entry.prototype.getAnswer = function() {
      return this.answer;
    };

    Entry.prototype.setAnswer = function(answer) {
      return this.answer = answer;
    };

    Entry.prototype.getAttributes = function() {
      return {
        date: this.getDate(),
        answer: this.getAnswer()
      };
    };

    return Entry;

  })();

  Node.prototype.prependChild = function(el) {
    return this.childNodes[0] && this.insertBefore(el, this.childNodes[0]) || this.appendChild(el);
  };

  app.View = (function() {
    function View(el) {
      if (el == null) {
        throw "Cannot construct view without an HTML element";
      }
      this.el = el;
      this.initialize();
      this.render();
      this.events();
    }

    View.prototype.initialize = function() {};

    View.prototype.render = function() {};

    View.prototype.events = function() {};

    return View;

  })();

  app.PromptView = (function(_super) {
    __extends(PromptView, _super);

    function PromptView() {
      return PromptView.__super__.constructor.apply(this, arguments);
    }

    PromptView.prototype.events = function() {
      return this.el.addEventListener('touchmove', function(e) {
        return e.preventDefault();
      });
    };

    PromptView.prototype.render = function() {
      return this.el.innerHTML = "<h1>" + app.prompt + "</h1>";
    };

    return PromptView;

  })(app.View);

  app.TogglingView = (function(_super) {
    __extends(TogglingView, _super);

    function TogglingView() {
      return TogglingView.__super__.constructor.apply(this, arguments);
    }

    TogglingView.prototype.events = function() {
      this.el.addEventListener('touchmove', function(e) {
        return e.preventDefault();
      });
      return document.addEventListener('entries:changed', this);
    };

    TogglingView.prototype.handleEvent = function(e) {
      if (e.type === 'entries:changed') {
        return this.onEntryChange(e);
      }
    };

    TogglingView.prototype.onEntryChange = function(e) {
      var entries, lastDate, lastEntry, now;
      entries = e.detail.collection.getRecords();
      lastEntry = entries.pop();
      lastDate = new Date(lastEntry != null ? lastEntry.date : void 0).setHours(0, 0, 0, 0) || 0;
      now = new Date().setHours(0, 0, 0, 0);
      return this.toggle(now, lastDate);
    };

    TogglingView.prototype.toggle = function(now, previously) {
      if (now > previously) {
        return this.show();
      } else {
        return this.hide();
      }
    };

    TogglingView.prototype.hide = function() {
      this.el.style.opacity = '0';
      this.el.style.zIndex = 0;
      return document.dispatchEvent(new CustomEvent('toggling_view:shown'));
    };

    TogglingView.prototype.show = function() {
      this.el.style.opacity = '1';
      this.el.style.zIndex = 1;
      return document.dispatchEvent(new CustomEvent('toggling_view:shown'));
    };

    return TogglingView;

  })(app.View);

  app.StatsView = (function(_super) {
    __extends(StatsView, _super);

    function StatsView() {
      return StatsView.__super__.constructor.apply(this, arguments);
    }

    StatsView.prototype.handleEvent = function(e) {
      if (e.type === 'entries:changed') {
        this.rerender(e);
      }
      return StatsView.__super__.handleEvent.apply(this, arguments);
    };

    StatsView.prototype.toggle = function(now, previously) {
      if (now <= previously) {
        return this.show();
      } else {
        return this.hide();
      }
    };

    StatsView.prototype.rerender = function(e) {
      var entries, noPct, yesPct;
      entries = e.detail.collection.getRecords();
      this.yeas = entries.filter(function(entry) {
        return entry.answer === 1;
      });
      this.nays = entries.filter(function(entry) {
        return entry.answer === 0;
      });
      yesPct = Math.floor(this.yeas.length / entries.length * 100);
      noPct = 100 - yesPct;
      return this.el.innerHTML = "<div class='percentages'> <div class='percentage percentage-yes' style='width: " + yesPct + "%'></div> <div class='percentage percentage-no' style='width: " + noPct + "%'></div> </div>";
    };

    return StatsView;

  })(app.TogglingView);

  app.InputView = (function(_super) {
    __extends(InputView, _super);

    function InputView() {
      return InputView.__super__.constructor.apply(this, arguments);
    }

    InputView.prototype.events = function() {
      this.el.addEventListener(app.CLICK_EVENT, this);
      this.el.addEventListener('touchcancel', this);
      return InputView.__super__.events.apply(this, arguments);
    };

    InputView.prototype.handleEvent = function(e) {
      if (e.type === app.CLICK_EVENT) {
        this.newEntry(e);
      }
      return InputView.__super__.handleEvent.apply(this, arguments);
    };

    InputView.prototype.newEntry = function(e) {
      var target, val;
      target = e.target;
      val = target.getAttribute('data-val');
      if (val != null) {
        return document.dispatchEvent(new CustomEvent('entry:create', {
          detail: {
            answer: parseInt(val)
          }
        }));
      }
    };

    InputView.prototype.render = function() {
      return this.el.innerHTML = "<div data-val=1 class='button button-yes'>Yes</div> <div data-val=0 class='button button-no'>No</div>";
    };

    return InputView;

  })(app.TogglingView);

  app.ScrollView = (function(_super) {
    __extends(ScrollView, _super);

    function ScrollView() {
      return ScrollView.__super__.constructor.apply(this, arguments);
    }

    ScrollView.prototype.events = function() {
      return this.el.addEventListener('touchstart', this);
    };

    ScrollView.prototype.handleEvent = function(e) {
      if (e.type === 'touchstart') {
        return this.onTouchStart(e);
      }
    };

    ScrollView.prototype.onTouchStart = function(e) {
      var atBottom, atTop, height;
      height = this.el.getBoundingClientRect().height;
      atTop = this.el.scrollTop === 0;
      atBottom = this.el.scrollHeight - this.el.scrollTop === height;
      if (atTop) {
        this.el.scrollTop += 1;
      }
      if (atBottom) {
        return this.el.scrollTop -= 1;
      }
    };

    return ScrollView;

  })(app.View);

  app.HistoryView = (function(_super) {
    __extends(HistoryView, _super);

    function HistoryView() {
      return HistoryView.__super__.constructor.apply(this, arguments);
    }

    HistoryView.prototype.initialize = function() {
      this.fragment = document.createDocumentFragment();
      return this.months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    };

    HistoryView.prototype.events = function() {
      document.addEventListener('entries:changed', this);
      document.addEventListener('topview:height', this);
      return document.addEventListener('app:loaded', this);
    };

    HistoryView.prototype.handleEvent = function(e) {
      if (e.type === 'entries:changed') {
        this.onEntryChange(e);
      }
      if (e.type === 'topview:height') {
        this.adjustHeight(e);
      }
      if (e.type === 'app:loaded') {
        return this.enableAnimation();
      }
    };

    HistoryView.prototype.enableAnimation = function() {
      return this.animate = true;
    };

    HistoryView.prototype.onEntryChange = function(event) {
      this.entries = event.detail.collection.getRecords();
      return this.render();
    };

    HistoryView.prototype.render = function() {
      var entry, _i, _len, _ref;
      this.el.innerHTML = '';
      if (this.entries != null) {
        _ref = this.entries.reverse();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          this.renderEntry(entry);
        }
      }
      return this.el.appendChild(this.fragment);
    };

    HistoryView.prototype.renderEntry = function(entry) {
      var date, elem;
      date = new Date(entry.date);
      elem = document.createElement('div');
      elem.className = "entry entry-" + entry.answer;
      elem.id = "entry_" + entry.date;
      elem.innerHTML = "<div class='entry_date'> " + this.months[date.getMonth()] + " " + (date.getDate()) + " </div> <div class='entry_answer'></div>";
      return this.fragment.appendChild(elem);
    };

    HistoryView.prototype.adjustHeight = function(e) {
      var offset;
      offset = e.detail.height;
      if (offset != null) {
        return this.el.style.top = offset + 'px';
      }
    };

    return HistoryView;

  })(app.View);

  app.TopView = (function(_super) {
    __extends(TopView, _super);

    function TopView() {
      return TopView.__super__.constructor.apply(this, arguments);
    }

    TopView.prototype.events = function() {
      document.addEventListener('toggling_view:shown', this);
      return window.addEventListener('orientationchange', this);
    };

    TopView.prototype.handleEvent = function() {
      return this.sendHeight();
    };

    TopView.prototype.sendHeight = function(e) {
      return document.dispatchEvent(new CustomEvent('topview:height', {
        detail: {
          height: this.el.offsetHeight
        }
      }));
    };

    return TopView;

  })(app.View);

}).call(this);
