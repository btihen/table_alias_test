# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the
#
# bin/rails db:seed
#
# command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
languages = Language.create([{key: 'en'}, {key: 'de'}, {key: 'it'}, {key: 'fr'}])
address = Address.create(street: 'Stampbachgasse 6', town: 'Bolligen')
owner = Person.create(name: 'Bill', address: address, language: languages.first)
renter = Person.create(name: 'Nyima', address: address, language: languages.second)
objekt = Objekt.create(owner: owner, address: address)
shine = Person.create(name: 'Shiné', address: address, language: languages.third)
ziji = Person.create(name: 'Ziji', address: address, language: languages.last)
objekt = Objekt.create(owner: owner, address: address)
lease0 = Lease.create(objekt: objekt, renter: renter, subletters: [shine, ziji])
lease1 = Lease.create(prior_lease: lease0, objekt: objekt, renter: renter, subletters: [shine])
lease2 = Lease.create(prior_lease: lease1, objekt: objekt, renter: renter, subletters: [ziji, owner])
# Lease.create(objekt: objekt, renter: renter)
