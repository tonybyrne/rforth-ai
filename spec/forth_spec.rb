require 'forth'

RSpec.describe Forth do
  let(:forth) { Forth.new }

  describe '#execute' do
    it 'pushes numbers onto the stack' do
      forth.execute("1 2 3")
      expect(forth.stack).to eq([1, 2, 3])
    end

    it 'performs addition' do
      forth.execute("1 2 +")
      expect(forth.stack).to eq([3])
    end

    it 'performs subtraction' do
      forth.execute("5 2 -")
      expect(forth.stack).to eq([3])
    end

    it 'performs multiplication' do
      forth.execute("3 4 *")
      expect(forth.stack).to eq([12])
    end

    it 'performs division' do
      forth.execute("12 4 /")
      expect(forth.stack).to eq([3])
    end

    it 'handles DUP' do
      forth.execute("1 dup")
      expect(forth.stack).to eq([1, 1])
    end

    it 'handles DROP' do
      forth.execute("1 2 drop")
      expect(forth.stack).to eq([1])
    end

    it 'handles SWAP' do
      forth.execute("1 2 swap")
      expect(forth.stack).to eq([2, 1])
    end

    it 'handles OVER' do
      forth.execute("1 2 over")
      expect(forth.stack).to eq([1, 2, 1])
    end

    it 'defines and executes new words' do
      forth.execute(": square dup * ;")
      forth.execute("5 square")
      expect(forth.stack).to eq([25])
    end

    it 'handles nested definitions or multiple calls' do
      forth.execute(": square dup * ;")
      forth.execute(": cube dup square * ;")
      forth.execute("3 cube")
      expect(forth.stack).to eq([27])
    end

    it 'is case-insensitive' do
      forth.execute("1 DUP")
      expect(forth.stack).to eq([1, 1])
    end

    it 'raises error for unknown words' do
      expect { forth.execute("foo") }.to raise_error(Forth::UnknownWord)
    end

    it 'raises error for stack underflow' do
      expect { forth.execute("+") }.to raise_error(Forth::StackUnderflow)
    end

    it 'handles equality comparison' do
      forth.execute("5 5 =")
      expect(forth.stack).to eq([-1])
      forth.execute("5 6 =")
      expect(forth.stack).to eq([-1, 0])
    end

    it 'handles less than comparison' do
      forth.execute("4 5 <")
      expect(forth.stack).to eq([-1])
      forth.execute("5 4 <")
      expect(forth.stack).to eq([-1, 0])
    end

    it 'handles greater than comparison' do
      forth.execute("5 4 >")
      expect(forth.stack).to eq([-1])
      forth.execute("4 5 >")
      expect(forth.stack).to eq([-1, 0])
    end

    it 'handles IF THEN' do
      forth.execute("1 if 10 then")
      expect(forth.stack).to eq([10])
      forth.execute("0 if 20 then")
      expect(forth.stack).to eq([10])
    end

    it 'handles IF ELSE THEN' do
      forth.execute("1 if 10 else 20 then")
      expect(forth.stack).to eq([10])
      forth.execute("0 if 30 else 40 then")
      expect(forth.stack).to eq([10, 40])
    end

    it 'handles nested IF' do
      forth.execute("1 if 1 if 100 then then")
      expect(forth.stack).to eq([100])
    end

    it 'handles variables' do
      forth.execute("variable count")
      forth.execute("10 count !")
      forth.execute("count @")
      expect(forth.stack).to eq([10])
    end

    it 'can increment variables' do
      forth.execute("variable x")
      forth.execute("5 x !")
      forth.execute("x @ 1 + x !")
      forth.execute("x @")
      expect(forth.stack).to eq([6])
    end

    it 'handles DO LOOP' do
      forth.execute("0 3 0 do 1 + loop")
      expect(forth.stack).to eq([3])
    end

    it 'handles DO LOOP with I' do
      forth.execute("3 0 do i loop")
      expect(forth.stack).to eq([0, 1, 2])
    end

    it 'handles nested DO LOOP' do
      forth.execute("2 0 do 2 0 do i loop loop")
      expect(forth.stack).to eq([0, 1, 0, 1])
    end

    it 'handles J in nested DO LOOP' do
      forth.execute("2 0 do 2 0 do j loop loop")
      expect(forth.stack).to eq([0, 0, 1, 1])
    end
  end
end
