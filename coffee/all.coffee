Ember.Handlebars.helper 'forecastdate', (date)->
	moment(date).format('dddd').substring(0,3)
Ember.Handlebars.helper 'mean-temperature', (temps)->
	values = (v for k,v of temps)
	Math.round((values.reduce (l, r) -> l + r) / values.length)
