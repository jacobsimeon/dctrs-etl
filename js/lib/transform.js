// Generated by CoffeeScript 1.7.1
(function() {
  var Dctr, csv;

  csv = require("csv");

  this.TransformDctrs = (function() {
    function TransformDctrs(_in, out) {
      this["in"] = _in;
      this.out = out;
    }

    TransformDctrs.prototype.transform = function() {
      return csv().from.stream(this["in"]).to.stream(this.out).transform(function(row, index, callback) {
        return process.nextTick(function() {
          var dctr;
          dctr = new Dctr(row);
          return callback(null, "" + (dctr.meta()) + "\n" + (dctr.json()) + "\n");
        });
      });
    };

    return TransformDctrs;

  })();

  Dctr = (function() {
    function Dctr(csv) {
      this.csv = csv;
    }

    Dctr.prototype.meta = function() {
      return JSON.stringify(this.metaAttrs());
    };

    Dctr.prototype.json = function() {
      return JSON.stringify(this.attrs());
    };

    Dctr.prototype.metaAttrs = function() {
      return {
        create: {
          _index: "dctrs",
          _type: "dctr",
          _id: this.npi()
        }
      };
    };

    Dctr.prototype.attrs = function() {
      return {
        npi: this.npi()
      };
    };

    Dctr.prototype.npi = function() {
      return this.csv[0];
    };

    return Dctr;

  })();

}).call(this);