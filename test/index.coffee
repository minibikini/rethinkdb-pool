'use strict'

Pool     = require "#{__dirname}/../"
{expect} = require 'chai'
co       = require 'co'

describe 'rethinkdb-pool', ->

  connection = undefined
  pool = undefined
  r = undefined

  before co -->
    pool = Pool {
      host: 'localhost'
      db: 'test'
    }

    {r} = pool

    yield pool.run r.tableCreate 'foo'

  after co -->
    yield pool.run r.tableDrop 'foo'

  beforeEach co -->
    connection = yield pool.acquire

  afterEach ->
    pool.release connection

  it 'should export rethinkdb client', ->
    expect(pool.r).to.exist
    expect(pool.Promise).to.exist

  it 'should acquire connection', co -->
    expect(connection).to.exist

  it 'should run query', co -->
    query  = r.tableList()
    result = yield pool.run query

    expect(result).to.be.an('array')

  it 'should return a promise', co -->
    yield pool.run r.table('foo').insert [
      {foo: 'bar'}
      {baz: 'nyan'}
    ]

    result = yield pool.run r.table('foo')
    expect(result).to.have.length.of(2)