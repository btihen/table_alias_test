# test when fk has name of variable!

bin/rails new aliases
cd aliases

bin/rails g model Language key
bin/rails g model Address street town
bin/rails g model Person name address:references language:references
bin/rails g model Objekt address:references owner:references # foreign_key: { to_table: :people }
bin/rails g model Lease objekt:references renter:references prior_lease:references # foreign_key: { to_table: :people }, foreign_key: { to_table: :leases }
bin/rails g model LeaseSubletters lease:references subletter:references # foreign_key: { to_table: :people }


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


bin/rails db:drop
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

bin/rails c


query = Lease
query = query.joins(:prior_lease)
query = query.joins(updated_leases: {renter: :language})
query = query.joins(renter: [:address, :language])
query = query.joins(subletters: [:address, :language])
query = query.joins(objekt: [:address, {owner: [:address, :language]}])


https://github.com/activerecord-hackery/meta_search/pull/79/files
join_nodes.each do |join|
  join_dependency.alias_tracker.aliased_name_for(join.left.name.downcase.to_s)
end


query.join_values
=> [{:renter=>:address},
 {:renter=>:language},
 {:subletters=>:address},
 {:subletters=>:language},
 {:objekt=>:address},
 {:objekt=>:owner},
 {:objekt=>{:owner=>:address}},
 {:objekt=>{:owner=>:language}}]

query.arel.join_sources
[#<Arel::Nodes::InnerJoin:0x00007fa5c7c7f410
  @left=
  @right=

query.alias_tracker

# query = query.includes(renter: :address)
# query = query.includes(renter: :language)
# query = query.includes(subletters: :address)
# query = query.includes(subletters: :language)
# query = query.includes(objekt: :address)
# query = query.includes(objekt: {owner: :address})
# query = query.includes(objekt: {owner: :language})

query.to_sql
=> "SELECT \"leases\".* FROM \"leases\" INNER JOIN \"people\" ON \"people\".\"id\" = \"leases\".\"renter_id\" INNER JOIN \"addresses\" ON \"addresses\".\"id\" = \"people\".\"address_id\" INNER JOIN \"languages\" ON \"languages\".\"id\" = \"people\".\"language_id\" INNER JOIN \"lease_subletters\" ON \"lease_subletters\".\"lease_id\" = \"leases\".\"id\" INNER JOIN \"people\" \"subletters_leases\" ON \"subletters_leases\".\"id\" = \"lease_subletters\".\"subletter_id\" INNER JOIN \"addresses\" \"addresses_people\" ON \"addresses_people\".\"id\" = \"subletters_leases\".\"address_id\" INNER JOIN \"languages\" \"languages_people\" ON \"languages_people\".\"id\" = \"subletters_leases\".\"language_id\" INNER JOIN \"objekts\" ON \"objekts\".\"id\" = \"leases\".\"objekt_id\" INNER JOIN \"addresses\" \"addresses_objekts\" ON \"addresses_objekts\".\"id\" = \"objekts\".\"address_id\" INNER JOIN \"people\" \"owners_objekts\" ON \"owners_objekts\".\"id\" = \"objekts\".\"owner_id\" INNER JOIN \"addresses\" \"addresses_people_2\" ON \"addresses_people_2\".\"id\" = \"owners_objekts\".\"address_id\" INNER JOIN \"languages\" \"languages_people_2\" ON \"languages_people_2\".\"id\" = \"owners_objekts\".\"language_id\""

query.to_sql.split(' INNER JOIN ')
=>
["SELECT \"leases\".* FROM \"leases\"",
 current_table_name                       current_table_alias                    parent_table_name      reference_name
 "\"people\"                           ON \"people\"             .\"id\"       = \"leases\"            .\"renter_id\"",
 "\"addresses\"                        ON \"addresses\"          .\"id\"       = \"people\"            .\"address_id\"",
 "\"languages\"                        ON \"languages\"          .\"id\"       = \"people\"            .\"language_id\"",
 "\"lease_subletters\"                 ON \"lease_subletters\"   .\"lease_id\" = \"leases\"            .\"id\"",
 "\"people\"    \"subletters_leases\"  ON \"subletters_leases\"  .\"id\"       = \"lease_subletters\"  .\"subletter_id\"",
 "\"addresses\" \"addresses_people\"   ON \"addresses_people\"   .\"id\"       = \"subletters_leases\" .\"address_id\"",
 "\"languages\" \"languages_people\"   ON \"languages_people\"   .\"id\"       = \"subletters_leases\" .\"language_id\"",
 "\"objekts\"                          ON \"objekts\"            .\"id\"       = \"leases\"            .\"objekt_id\"",
 "\"addresses\" \"addresses_objekts\"  ON \"addresses_objekts\"  .\"id\"       = \"objekts\"           .\"address_id\"",
 "\"people\"    \"owners_objekts\"     ON \"owners_objekts\"     .\"id\"       = \"objekts\"           .\"owner_id\"",
 "\"addresses\" \"addresses_people_2\" ON \"addresses_people_2\" .\"id\"       = \"owners_objekts\"    .\"address_id\"",
 "\"languages\" \"languages_people_2\" ON \"languages_people_2\" .\"id\"       = \"owners_objekts\"    .\"language_id\""]

InnerJoin[11] (objekt.owner.address)
owner.address
                               @right.expr.left.relation.left.name (table)  @right.expr.right.relation.left.name(table)
@left.left.name (table)                @right.expr.left.relation.right          @right.expr.right.relation.right
                 @left.right                               @right.expr.left.name                   @right.expr.right.name

 "\"languages\" \"languages_people_2\" ON \"languages_people_2\" .\"id\"       = \"owners_objekts\"    .\"language_id\""]

# get subletter names
w_select = query.select('subletters_leases.name AS sub_name')
results = ActiveRecord::Base.connection.execute(w_select.to_sql).values

query.arel.join_sources
 =>
 [#<Arel::Nodes::InnerJoin:0x00007fa5c7c7f410
   @left=
    #<Arel::Table:0x00007fa5cc8a7798
     @klass=
      Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
     @name="people",
     @table_alias=nil,
     @type_caster=
      #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
       @klass=
        Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
   @right=
    #<Arel::Nodes::On:0x00007fa5c7c7f460
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c7c847d0
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5cc8a7798
           @klass=
            Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
           @name="people",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
             @klass=
              Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5cc815aa0
           @klass=Lease(id: integer, objekt_id: integer, renter_id: integer, created_at: datetime, updated_at: datetime),
           @name="leases",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8159b0
             @klass=
              Lease(id: integer, objekt_id: integer, renter_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="renter_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c7c7d930
   @left=
    #<Arel::Table:0x00007fa5c7cf8040
     @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime),
     @name="addresses",
     @table_alias=nil,
     @type_caster=
      #<ActiveRecord::TypeCaster::Map:0x00007fa5c7e7bfc0
       @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime)>>,
   @right=
    #<Arel::Nodes::On:0x00007fa5c7c7d980
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c7c7e420
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5c7cf8040
           @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime),
           @name="addresses",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5c7e7bfc0
             @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime)>>,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5cc8a7798
           @klass=
            Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
           @name="people",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
             @klass=
              Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="address_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c7c76ec8
   @left=
    #<Arel::Table:0x00007fa5cc8af6f0
     @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime),
     @name="languages",
     @table_alias=nil,
     @type_caster=
      #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8af6a0
       @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime)>>,
   @right=
    #<Arel::Nodes::On:0x00007fa5c7c76f40
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c7c77fd0
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5cc8af6f0
           @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime),
           @name="languages",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8af6a0
             @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime)>>,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5cc8a7798
           @klass=
            Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
           @name="people",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
             @klass=
              Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="language_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c7c4fc10
   @left=
    #<Arel::Table:0x00007fa5cc8c48c0
     @klass=
      LeaseSubletter(id: integer, lease_id: integer, subletter_id: integer, created_at: datetime, updated_at: datetime),
     @name="lease_subletters",
     @table_alias=nil,
     @type_caster=
      #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8c4848
       @klass=
        LeaseSubletter(id: integer, lease_id: integer, subletter_id: integer, created_at: datetime, updated_at: datetime)>>,
   @right=
    #<Arel::Nodes::On:0x00007fa5c7c4fc60
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c7c74c68
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5cc8c48c0
           @klass=
            LeaseSubletter(id: integer, lease_id: integer, subletter_id: integer, created_at: datetime, updated_at: datetime),
           @name="lease_subletters",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8c4848
             @klass=
              LeaseSubletter(id: integer, lease_id: integer, subletter_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="lease_id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5cc815aa0
           @klass=Lease(id: integer, objekt_id: integer, renter_id: integer, created_at: datetime, updated_at: datetime),
           @name="leases",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8159b0
             @klass=
              Lease(id: integer, objekt_id: integer, renter_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c7c4d168
   @left=
    #<Arel::Nodes::TableAlias:0x00007fa5c7c758e8
     @left=
      #<Arel::Table:0x00007fa5cc8a7798
       @klass=
        Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
       @name="people",
       @table_alias=nil,
       @type_caster=
        #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
         @klass=
          Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
     @right="subletters_leases">,
   @right=
    #<Arel::Nodes::On:0x00007fa5c7c4d190
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c7c4e4a0
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c7c758e8
           @left=
            #<Arel::Table:0x00007fa5cc8a7798
             @klass=
              Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
             @name="people",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
               @klass=
                Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
           @right="subletters_leases">,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5cc8c48c0
           @klass=
            LeaseSubletter(id: integer, lease_id: integer, subletter_id: integer, created_at: datetime, updated_at: datetime),
           @name="lease_subletters",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8c4848
             @klass=
              LeaseSubletter(id: integer, lease_id: integer, subletter_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="subletter_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c7c6d760
   @left=
    #<Arel::Nodes::TableAlias:0x00007fa5c7c4ca38
     @left=
      #<Arel::Table:0x00007fa5c7cf8040
       @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime),
       @name="addresses",
       @table_alias=nil,
       @type_caster=
        #<ActiveRecord::TypeCaster::Map:0x00007fa5c7e7bfc0
         @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime)>>,
     @right="addresses_people">,
   @right=
    #<Arel::Nodes::On:0x00007fa5c7c6d7d8
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c7c6ed68
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c7c4ca38
           @left=
            #<Arel::Table:0x00007fa5c7cf8040
             @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime),
             @name="addresses",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5c7e7bfc0
               @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime)>>,
           @right="addresses_people">,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c7c758e8
           @left=
            #<Arel::Table:0x00007fa5cc8a7798
             @klass=
              Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
             @name="people",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
               @klass=
                Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
           @right="subletters_leases">,
         name="address_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c7c42768
   @left=
    #<Arel::Nodes::TableAlias:0x00007fa5c7c6d418
     @left=
      #<Arel::Table:0x00007fa5cc8af6f0
       @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime),
       @name="languages",
       @table_alias=nil,
       @type_caster=
        #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8af6a0
         @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime)>>,
     @right="languages_people">,
   @right=
    #<Arel::Nodes::On:0x00007fa5c7c427e0
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c7c43190
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c7c6d418
           @left=
            #<Arel::Table:0x00007fa5cc8af6f0
             @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime),
             @name="languages",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8af6a0
               @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime)>>,
           @right="languages_people">,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c7c758e8
           @left=
            #<Arel::Table:0x00007fa5cc8a7798
             @klass=
              Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
             @name="people",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
               @klass=
                Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
           @right="subletters_leases">,
         name="language_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c94c30d0
   @left=
    #<Arel::Table:0x00007fa5c7ff9d20
     @klass=Objekt(id: integer, address_id: integer, owner_id: integer, created_at: datetime, updated_at: datetime),
     @name="objekts",
     @table_alias=nil,
     @type_caster=
      #<ActiveRecord::TypeCaster::Map:0x00007fa5c7ff9ca8
       @klass=Objekt(id: integer, address_id: integer, owner_id: integer, created_at: datetime, updated_at: datetime)>>,
   @right=
    #<Arel::Nodes::On:0x00007fa5c94c3120
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c94c3a80
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5c7ff9d20
           @klass=
            Objekt(id: integer, address_id: integer, owner_id: integer, created_at: datetime, updated_at: datetime),
           @name="objekts",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5c7ff9ca8
             @klass=
              Objekt(id: integer, address_id: integer, owner_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5cc815aa0
           @klass=Lease(id: integer, objekt_id: integer, renter_id: integer, created_at: datetime, updated_at: datetime),
           @name="leases",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8159b0
             @klass=
              Lease(id: integer, objekt_id: integer, renter_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="objekt_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c94a9310
   @left=
    #<Arel::Nodes::TableAlias:0x00007fa5c94c2ba8
     @left=
      #<Arel::Table:0x00007fa5c7cf8040
       @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime),
       @name="addresses",
       @table_alias=nil,
       @type_caster=
        #<ActiveRecord::TypeCaster::Map:0x00007fa5c7e7bfc0
         @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime)>>,
     @right="addresses_objekts">,
   @right=
    #<Arel::Nodes::On:0x00007fa5c94a9360
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c94c07e0
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c94c2ba8
           @left=
            #<Arel::Table:0x00007fa5c7cf8040
             @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime),
             @name="addresses",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5c7e7bfc0
               @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime)>>,
           @right="addresses_objekts">,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5c7ff9d20
           @klass=
            Objekt(id: integer, address_id: integer, owner_id: integer, created_at: datetime, updated_at: datetime),
           @name="objekts",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5c7ff9ca8
             @klass=
              Objekt(id: integer, address_id: integer, owner_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="address_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c737f450
   @left=
    #<Arel::Nodes::TableAlias:0x00007fa5c94a8f28
     @left=
      #<Arel::Table:0x00007fa5cc8a7798
       @klass=
        Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
       @name="people",
       @table_alias=nil,
       @type_caster=
        #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
         @klass=
          Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
     @right="owners_objekts">,
   @right=
    #<Arel::Nodes::On:0x00007fa5c737f590
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c94a0490
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c94a8f28
           @left=
            #<Arel::Table:0x00007fa5cc8a7798
             @klass=
              Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
             @name="people",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
               @klass=
                Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
           @right="owners_objekts">,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Table:0x00007fa5c7ff9d20
           @klass=
            Objekt(id: integer, address_id: integer, owner_id: integer, created_at: datetime, updated_at: datetime),
           @name="objekts",
           @table_alias=nil,
           @type_caster=
            #<ActiveRecord::TypeCaster::Map:0x00007fa5c7ff9ca8
             @klass=
              Objekt(id: integer, address_id: integer, owner_id: integer, created_at: datetime, updated_at: datetime)>>,
         name="owner_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c949b5f8
   @left=
    #<Arel::Nodes::TableAlias:0x00007fa5c737ef00
     @left=
      #<Arel::Table:0x00007fa5c7cf8040
       @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime),
       @name="addresses",
       @table_alias=nil,
       @type_caster=
        #<ActiveRecord::TypeCaster::Map:0x00007fa5c7e7bfc0
         @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime)>>,
     @right="addresses_people_2">,
   @right=
    #<Arel::Nodes::On:0x00007fa5c949b620
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c737e0a0
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c737ef00
           @left=
            #<Arel::Table:0x00007fa5c7cf8040
             @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime),
             @name="addresses",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5c7e7bfc0
               @klass=Address(id: integer, street: string, town: string, created_at: datetime, updated_at: datetime)>>,
           @right="addresses_people_2">,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c94a8f28
           @left=
            #<Arel::Table:0x00007fa5cc8a7798
             @klass=
              Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
             @name="people",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
               @klass=
                Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
           @right="owners_objekts">,
         name="address_id">>>>,
  #<Arel::Nodes::InnerJoin:0x00007fa5c736e588
   @left=
    #<Arel::Nodes::TableAlias:0x00007fa5c7375478
     @left=
      #<Arel::Table:0x00007fa5cc8af6f0
       @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime),
       @name="languages",
       @table_alias=nil,
       @type_caster=
        #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8af6a0
         @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime)>>,
     @right="languages_people_2">,
   @right=
    #<Arel::Nodes::On:0x00007fa5c736e5d8
     @expr=
      #<Arel::Nodes::Equality:0x00007fa5c736f640
       @left=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c7375478
           @left=
            #<Arel::Table:0x00007fa5cc8af6f0
             @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime),
             @name="languages",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8af6a0
               @klass=Language(id: integer, key: string, created_at: datetime, updated_at: datetime)>>,
           @right="languages_people_2">,
         name="id">,
       @right=
        #<struct Arel::Attributes::Attribute
         relation=
          #<Arel::Nodes::TableAlias:0x00007fa5c94a8f28
           @left=
            #<Arel::Table:0x00007fa5cc8a7798
             @klass=
              Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime),
             @name="people",
             @table_alias=nil,
             @type_caster=
              #<ActiveRecord::TypeCaster::Map:0x00007fa5cc8a7720
               @klass=
                Person(id: integer, name: string, address_id: integer, language_id: integer, created_at: datetime, updated_at: datetime)>>,
           @right="owners_objekts">,
         name="language_id">>>>]









query = Lease
query = query.joins(objekt: :address)
query = query.joins(renter: [:address, :language])
query = query.joins(subletters: [:address, :language])
query = query.joins(objekt: [:address, {owner: [:address, :language]}])

query.to_sql
=>
SELECT "leases".* FROM "leases" INNER JOIN "objekts" ON "objekts"."id" = "leases"."objekt_id" INNER JOIN "addresses" ON "addresses"."id" = "objekts"."address_id" INNER JOIN "people" ON "people"."id" = "objekts"."owner_id" INNER JOIN "addresses" "addresses_people" ON "addresses_people"."id" = "people"."address_id" INNER JOIN "languages" ON "languages"."id" = "people"."language_id" INNER JOIN "people" "renters_leases" ON "renters_leases"."id" = "leases"."renter_id" INNER JOIN "addresses" "addresses_people_2" ON "addresses_people_2"."id" = "renters_leases"."address_id" INNER JOIN "languages" "languages_people" ON "languages_people"."id" = "renters_leases"."language_id" INNER JOIN "lease_subletters" ON "lease_subletters"."lease_id" = "leases"."id" INNER JOIN "people" "subletters_leases" ON "subletters_leases"."id" = "lease_subletters"."subletter_id" INNER JOIN "addresses" "addresses_people_3" ON "addresses_people_3"."id" = "subletters_leases"."address_id" INNER JOIN "languages" "languages_people_2" ON "languages_people_2"."id" = "subletters_leases"."language_id"

query.to_sql.split(' INNER JOIN ')
=>
["SELECT \"leases\".* FROM \"leases\"",
 "\"objekts\"                          ON \"objekts\"            .\"id\"       = \"leases\"            .\"objekt_id\"",
 "\"addresses\"                        ON \"addresses\"          .\"id\"       = \"objekts\"           .\"address_id\"",
 "\"people\"                           ON \"people\"             .\"id\"       = \"objekts\"           .\"owner_id\"",
 "\"addresses\" \"addresses_people\"   ON \"addresses_people\"   .\"id\"       = \"people\"            .\"address_id\"",
 "\"languages\"                        ON \"languages\"          .\"id\"       = \"people\"            .\"language_id\"",
 "\"people\"    \"renters_leases\"     ON \"renters_leases\"     .\"id\"       = \"leases\"            .\"renter_id\"",
 "\"addresses\" \"addresses_people_2\" ON \"addresses_people_2\" .\"id\"       = \"renters_leases\"    .\"address_id\"",
 "\"languages\" \"languages_people\"   ON \"languages_people\"   .\"id\"       = \"renters_leases\"    .\"language_id\"",
 "\"lease_subletters\"                 ON \"lease_subletters\"   .\"lease_id\" = \"leases\"            .\"id\"",
 "\"people\"    \"subletters_leases\"  ON \"subletters_leases\"  .\"id\"       = \"lease_subletters\"  .\"subletter_id\"",
 "\"addresses\" \"addresses_people_3\" ON \"addresses_people_3\" .\"id\"       = \"subletters_leases\" .\"address_id\"",
 "\"languages\" \"languages_people_2\" ON \"languages_people_2\" .\"id\"       = \"subletters_leases\" .\"language_id\""]




base_query = Lease
rent_addr_q = base_query.joins(renter: :address)
rent_lang_q = rent_addr_q.joins(renter: :language)
apt_addr_q = rent_lang_q.joins(objekt: :address)
own_addr_q = apt_addr_q.joins(objekt: {owner: :address})
own_lang_q = own_addr_q.joins(objekt: {owner: :language})

rent_addr_j = rent_addr_q.to_sql.split(' INNER JOIN ')
rent_lang_j = rent_lang_q.to_sql.split(' INNER JOIN ')
apt_addr_j = apt_addr_q.to_sql.split(' INNER JOIN ')
own_addr_j = own_addr_q.to_sql.split(' INNER JOIN ')
own_lang_j = own_lang_q.to_sql.split(' INNER JOIN ')

rent_addr_o = rent_addr_j.dup
rent_lang_o = rent_lang_j - rent_addr_j
apt_addr_o = apt_addr_j - rent_lang_j
own_addr_o = own_addr_j - apt_addr_j
own_lang_o = own_lang_j - own_addr_j


["SELECT \"leases\".* FROM \"leases\"",
 "\"people\" ON \"people\".\"id\" = \"leases\".\"renter_id\"",
 "\"addresses\" ON \"addresses\".\"id\" = \"people\".\"address_id\"",
 "\"languages\" ON \"languages\".\"id\" = \"people\".\"language_id\"",
 "\"objekts\" ON \"objekts\".\"id\" = \"leases\".\"objekt_id\"",
 "\"addresses\" \"addresses_objekts\" ON \"addresses_objekts\".\"id\" = \"objekts\".\"address_id\"",
 "\"people\" \"owners_objekts\" ON \"owners_objekts\".\"id\" = \"objekts\".\"owner_id\"",
 "\"addresses\" \"addresses_people\" ON \"addresses_people\".\"id\" = \"owners_objekts\".\"address_id\"",
 "\"languages\" \"languages_people\" ON \"languages_people\".\"id\" = \"owners_objekts\".\"language_id\""]
