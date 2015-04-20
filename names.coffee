request = require 'request'
cheerio = require 'cheerio'

urlINE = (name, gender) =>
	return 'http://www.ine.es/tnombres/formGeneralresult.do?vista=1&orig=ine&cmb4=99&cmb7=' + (if gender==0 then 6 else 1) + '&cmb6=' + name

exports.genders = {
	male: 1
	female: 0
}

exports.getStatsForName = (name, gender, callback) =>
	request.get urlINE(name, gender), (err, response, body) =>
		if err or (response.statusCode isnt 200)
			console.log 'Ups!'
			callback err
		else
			$ = cheerio.load(body)
			avgAge = $('td.parrafoinfobold').text()
			avgAge = parseFloat avgAge.substr(avgAge.indexOf('media:') + 7, 4).replace(',','.')

			totalStats = {}
			resultsPerProvince = []
			$('table[summary="resultados"] tr.normal').each (i,elem) =>
				
				stats = 
					province: $(elem).find('th').text().trim()
					count: parseInt $(elem).find('td').eq(0).text().replace('.','')
					permille: parseFloat $(elem).find('td').eq(1).text().replace(',','.')
				if stats.province isnt 'Total'
					resultsPerProvince.push stats
				else
					delete stats.province
					totalStats = stats

			err = if totalStats.count? then null else new Error("No results")
			callback err, 
				averageAge: avgAge
				total: totalStats
				perProvince: resultsPerProvince
