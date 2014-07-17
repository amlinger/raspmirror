var WebsocketRESTAdapter, simpleConvertXML, weatherMap;

WebsocketRESTAdapter = DS.Adapter.extend({
  defaultSerializer: '-rest',
  init: function() {
    return null;
  },
  updatedModel: function() {
    return null;
  },
  createRecord: function() {
    return null;
  },
  updateRecord: function() {
    return null;
  },
  deleteRecord: function() {
    return null;
  },
  find: function(store, type, id) {
    return {
      'category': {
        'id': 14,
        'name': 'hej',
        'created_at': new Date().toTimeString(),
        'updated_at': new Date().toTimeString()
      }
    };
  },
  findMany: function() {
    return null;
  },
  findAll: function(store, type, sinceToken) {
    query;
    var query;
    if (sinceToken) {
      return query = {
        since: sinceToken
      };
    }
  },
  findQuery: function(store, type, query) {
    return null;
  }
});

Ember.Handlebars.helper('forecastdate', function(date) {
  return moment(date).format('dddd').substring(0, 3);
});

Ember.Handlebars.helper('mean-temperature', function(temps) {
  var k, v, values;
  values = (function() {
    var _results;
    _results = [];
    for (k in temps) {
      v = temps[k];
      _results.push(v);
    }
    return _results;
  })();
  return "" + (Math.round((values.reduce(function(l, r) {
    return l + r;
  })) / values.length)) + "°";
});

window.MagicMirror = Ember.Application.create({
  LOG_TRANSITIONS: true
});

MagicMirror.ApplicationAdapter = WebsocketRESTAdapter;

MagicMirror.Router.map(function() {
  return this.route('application', {
    path: '/'
  });
});

MagicMirror.ObjectTransform = DS.Transform.extend({
  serialize: function(serialized) {
    if (Ember.isNone(serialized)) {
      return {};
    } else {
      return serialized;
    }
  },
  deserialize: function(deserialized) {
    if (Ember.isNone(deserialized)) {
      return {};
    } else {
      return deserialized;
    }
  }
});

simpleConvertXML = (function() {
  var isArray;
  isArray = function(obj) {
    if (typeof obj === "object" && obj) {
      if (!obj.propertyIsEnumerable("length")) {
        return typeof obj.length === "number";
      }
    }
    return false;
  };
  return {
    isArray: isArray,
    getObjAsXMLstr: function(data) {
      var getAsNodeLeaf, getAsNodeParent, getNode, getNodeTree, nodeLeafStr, nodeParentStr, xmlStr;
      getAsNodeLeaf = function(name, content) {
        return nodeLeafStr.replace(/:name/g, name).replace(/:v/, getNodeTree(content));
      };
      getAsNodeParent = function(name, content) {
        return nodeParentStr.replace(/:name/g, name).replace(/:v/, getNodeTree(content));
      };
      getNode = function(name, content) {
        if (isArray(content)) {
          return content.map(function(p) {
            return getNode(name, p);
          }).join("");
        } else if (typeof content === "object") {
          return getAsNodeParent(name, content);
        } else {
          if (typeof content === "string") {
            return getAsNodeLeaf(name, content);
          }
        }
      };
      getNodeTree = function(obj) {
        var name, xmlStr;
        xmlStr = "";
        if (obj && typeof obj === "object") {
          for (name in obj) {
            xmlStr += getNode(name, obj[name]);
          }
        } else {
          if (typeof obj === "string") {
            xmlStr += obj.toString();
          }
        }
        return xmlStr;
      };
      xmlStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
      nodeParentStr = "<:name>\n:v</:name>\n";
      nodeLeafStr = "<:name>:v</:name>\n";
      xmlStr += getNodeTree(data);
      return xmlStr;
    },
    getXMLAsObj: function(xmlObj) {
      var getNodeAsArr, getWithAttributes, getXMLAsObj;
      getNodeAsArr = function(nodeChild) {
        var finObj, nodeName, nodeObj, o;
        nodeObj = getXMLAsObj(nodeChild);
        nodeName = nodeChild.nodeName;
        finObj = void 0;
        for (o in nodeObj) {
          if (nodeObj.hasOwnProperty(o)) {
            if (isArray(nodeObj[o])) {
              finObj = nodeObj[o];
            } else {
              finObj = [nodeObj[o]];
            }
          }
        }
        return finObj;
      };
      getWithAttributes = function(val, node) {
        var attr, attrArr, newObj, x;
        attrArr = node.attributes;
        attr = void 0;
        x = void 0;
        newObj = void 0;
        if (attrArr) {
          if (isArray(val)) {
            newObj = val;
          } else if (typeof val === "object") {
            newObj = val;
            x = attrArr.length;
            while (x--) {
              val[attrArr[x].name] = attrArr[x].nodeValue;
            }
          } else if (typeof val === "string") {
            if (attrArr.length) {
              newObj = {};
              x = attrArr.length;
              while (x--) {
                if (val) {
                  newObj[attrArr[x].nodeValue] = val;
                } else {
                  newObj[attrArr[x].name] = attrArr[x].nodeValue;
                }
              }
            }
          } else {
            newObj = val;
          }
        }
        return newObj || val;
      };
      getXMLAsObj = function(node) {
        var attr, attrArr, finObj, isStr, nodeName, nodeType, strObj, x;
        nodeName = void 0;
        nodeType = void 0;
        strObj = "";
        finObj = {};
        isStr = true;
        x = void 0;
        attr = void 0;
        attrArr = void 0;
        if (node) {
          if (node.hasChildNodes()) {
            node = node.firstChild;
            while (true) {
              nodeType = node.nodeType;
              nodeName = node.nodeName;
              if (nodeType === 1) {
                isStr = false;
                if (nodeName.match(/Arr\b/)) {
                  finObj[nodeName] = getNodeAsArr(node);
                } else if (finObj[nodeName]) {
                  if (isArray(finObj[nodeName])) {
                    finObj[nodeName].push(getWithAttributes(getXMLAsObj(node), node));
                  } else {
                    finObj[nodeName] = [finObj[nodeName]];
                    finObj[nodeName].push(getWithAttributes(getXMLAsObj(node), node));
                  }
                } else {
                  finObj[nodeName] = getWithAttributes(getXMLAsObj(node), node);
                }
              } else {
                if (nodeType === 3) {
                  strObj += node.nodeValue;
                }
              }
              if (!(node = node.nextSibling)) {
                break;
              }
            }
          }
          if (isStr) {
            return strObj;
          } else {
            return finObj;
          }
        }
      };
      isArray = this.isArray;
      return getXMLAsObj(xmlObj);
    }
  };
})();

MagicMirror.Location = DS.Model.extend({
  city: DS.attr('string'),
  abbr: DS.attr('string'),
  country: null
});

MagicMirror.LocationController = Ember.ObjectController.extend({
  time: (function() {
    console.log(this.get('model'));
    return moment().format("hh:mm");
  }).property('model')
});

MagicMirror.LocationAdapter = DS.RESTAdapter.extend({
  host: 'http://ipinfo.io',
  service: '',
  buildURL: function(type, id) {
    return "" + (this.get('host'));
  },
  find: function(id) {
    var deferred;
    deferred = new Ember.$.Deferred();
    $.getJSON(this.buildURL()).then((function(_this) {
      return function(location) {
        return deferred.resolve({
          'location': {
            'id': 1,
            'city': location.city,
            'abbr': location.country
          }
        });
      };
    })(this), (function(_this) {
      return function(error) {
        return deferred.resolve({
          'location': {
            'id': 1,
            'city': 'Stockholm',
            'abbr': 'SE'
          }
        });
      };
    })(this));
    return deferred.promise();
  },
  findAll: function(store, type, sinceToken) {
    return this.find();
  }
});

weatherMap = {
  '01d': '2',
  '02d': '8',
  '03d': '32',
  '04d': '41',
  '09d': '35',
  '01n': '3',
  '02n': '9',
  '03n': '14',
  '04n': '25',
  '09n': '18',
  '10d': '34',
  '11d': '33',
  '13d': '39',
  '50d': '13',
  '10n': '17',
  '11n': '15',
  '13n': '23',
  '50n': '13'
};

MagicMirror.Forecast = DS.Model.extend({
  dt: DS.attr('date'),
  temp: DS.attr('object'),
  weather: DS.attr('object')
});

MagicMirror.ForecastAdapter = DS.RESTAdapter.extend({
  host: 'http://api.openweathermap.org/data/2.5',
  service: 'forecast/daily',
  buildURL: function(city, country) {
    return "" + this.host + "/" + this.service + "?q=" + city + "," + country + "&units=metric&cnt=7";
  },
  findAll: function(store, type, sinceToken) {
    var deferred, prepare;
    prepare = function(o) {
      var _ref;
      _ref = [o.dt, o.dt * 1000, o.weather[0]], o.id = _ref[0], o.dt = _ref[1], o.weather = _ref[2];
      o.weather.icon = "static/images/" + weatherMap[o.weather.icon] + ".svg";
      return o;
    };
    deferred = new Ember.$.Deferred();
    store.find('location', 1).then((function(_this) {
      return function(loc) {
        var url;
        url = _this.buildURL(loc.get('city'), loc.get('abbr'));
        return Ember.$.getJSON(url).then(function(response) {
          var x;
          return deferred.resolve({
            'forecasts': (function() {
              var _i, _len, _ref, _results;
              _ref = response.list;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                x = _ref[_i];
                _results.push(prepare(x));
              }
              return _results;
            })()
          });
        }, function(error) {
          return deferred.resolve({
            'forecasts': []
          });
        });
      };
    })(this));
    return deferred.promise();
  }
});

MagicMirror.ApplicationRoute = Ember.Route.extend({
  model: function() {
    return new Ember.RSVP.Promise((function(_this) {
      return function(resolve, reject) {
        return new Ember.RSVP.hash({
          location: _this.store.find('location', 1),
          forecasts: _this.store.findAll('forecast')
        }).then(function(result) {
          return resolve({
            location: result.location,
            forecasts: result.forecasts
          });
        });
      };
    })(this));
  }
});
