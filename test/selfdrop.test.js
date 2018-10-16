const should = require('chai')
  .use(require('bn-chai')(web3.utils.BN))
  .use(require('chai-as-promised'))
.should();
ERROR_MSG = 'VM Exception while processing transaction: revert';


const TestToken = artifacts.require("TestToken.sol");
const SelfDrop = artifacts.require("SelfDrop.sol");

const {toWei, toBN} = web3.utils;

const duration = {
    seconds: function (val) { return val; },
    minutes: function (val) { return val * this.seconds(60); },
    hours: function (val) { return val * this.minutes(60); },
    days: function (val) { return val * this.hours(24); },
    weeks: function (val) { return val * this.days(7); },
    years: function (val) { return val * this.days(365); },
};
  
contract('Test', async (accounts) => {
    let owner = accounts[0];
    let randomAddress = accounts[5];
    let token, selfdrop;
    const timeNow = Math.floor(Date.now() / 1000 );
    let endTime = timeNow + duration.weeks(1);
    beforeEach('setup contract for tests', async () => {
        token = await TestToken.new({from: owner})
        selfdrop = await SelfDrop.new(token.address, timeNow, endTime);
        await token.transfer(selfdrop.address, toWei('2000'));
    })
    describe('does', async () => {
        it('test', async () => {
            await selfdrop.sendTransaction({
                from: accounts[1]
            });
            (await token.balanceOf(accounts[1])).should.be.eq.BN(toWei('1000'));
            await selfdrop.sendTransaction({
                from: accounts[1]
            });
            (await token.balanceOf(accounts[1])).should.be.eq.BN(toWei('1000'));
            await selfdrop.sendTransaction({
                from: accounts[2]
            });

            await selfdrop.sendTransaction({
                from: accounts[3]
            }).should.be.rejected;
        })
    })
})