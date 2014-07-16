Ember.Handlebars.helper 'forecastdate', (date)->
	moment(date).format('dddd')
