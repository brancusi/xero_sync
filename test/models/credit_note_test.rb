require 'test_helper'

class CreditNoteTest < ActiveSupport::TestCase

  def stub_credit_note
    Item.create(name:'Sunseed Chorizo')

    company = Company.create(name:'Nature Well')
    location = Location.create(name:'Silverlake', code:'NW001', company:company)

    CreditNote.new(location:location, date:Date.parse('2016-03-01'))
  end

  test "should generate a credit_note_number after created with CR prefix" do
    credit_note = stub_credit_note

    refute credit_note.credit_note_number.present?

    credit_note.save

    credit_reg = /CR-/
    assert_equal(0, credit_note.credit_note_number =~ credit_reg)
  end

  test "should only generate credit_note_number once on create" do
    credit_note = stub_credit_note

    credit_note_spy = Spy.on(credit_note, :generate_credit_note_number)

    credit_note.save

    credit_note.date = Date.today + 2

    credit_note.save

    assert credit_note_spy.has_been_called?
    assert_equal 1, credit_note_spy.calls.count
  end

  test "can transition from submitted to synced" do
    credit_note = stub_credit_note
    credit_note.save

    assert credit_note.submitted?
    credit_note.mark_synced!
    assert credit_note.synced?
  end

  test "can void submitted credit_notes" do
    credit_note = stub_credit_note
    credit_note.save

    assert credit_note.submitted?
    credit_note.void!
    assert credit_note.voided?
  end

  test "can void synced credit_notes" do
    credit_note = stub_credit_note
    credit_note.save

    credit_note.mark_synced!
    assert credit_note.synced?

    credit_note.void!

    assert credit_note.voided?
  end

end
