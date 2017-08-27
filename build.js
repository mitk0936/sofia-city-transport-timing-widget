/*
	Node scripts for building and configuring the hardware device.
	Used npm commands:
	
	npm run mkfs
	To clear the filesystem of the connected device.
	
	npm run upload
	npm run upload prod
	To take all the lua source code from the src/ folder and to upload it on the connected microcontroller.
	
	npm run config
	To upload the config.json file with the prepared system configurations.

	npm start
	To start the lua terminal inside the console, reading prints from the connected hardware device.
	
	npm run flash
	To flash the bin firmware to connected device (esptool.py is dependency)
*/
const cli = require('commander')
const prompt = require('prompt')
prompt.start();

require('shelljs/global')

const nodemcuToolPath = 'node_modules/nodemcu-tool/bin'
const pathToSrc = '../../..'

/* setting default options, used by the NodeMCU-Tool */
const options = `--connection-delay 400 --optimize --baud 115200`
const flashАddresses = ['0x7c000', '0xfc000', '0x1fc000', '0x3fc000', '0x7fc000', '0xffc000', '0x00000']

/*
	findPort - function which finds connected device on USB port,
	returns success callback and passes the port name to it.
	Throws an error if no devices are found, or more than 1 devices are connected
*/
const findPort = function (onSuccess) {
	const serialport = require('serialport')
	const portsFound = []

	serialport.list(function (err, ports) {
		if (err) {
			throw 'Error occured with finding connected device on USB port.'
		}

		ports.forEach(function(port) {
			if (port.serialNumber || port.manufacturer) {
				console.log('Found device on ', port.comName)
				portsFound.push(port.comName)
			}
		})

		switch (portsFound.length) {
			case 1:
				onSuccess(portsFound[0])
				break
			case 0:
				throw 'No connected devices were found.'
				break
			default:
				throw 'More than one devices were found.'
		}
	})
}

const selectAddress = function (onSuccess) {
	console.log('Please choose memory address for the binary to flash on...')

	flashАddresses.forEach(function (address, index) {
		console.log(`${index}) ${address}`)
	})

	prompt.get([{
		name: 'binary-flash-address-index',
		required: true
	}], function (err, result) {
		if (err) {
			throw 'Error with selecting memory address'
		}

		const selectedIndex = parseInt(result['binary-flash-address-index'])
		onSuccess(flashАddresses[selectedIndex])
	})
}

/*
	Command for clearing the device file system.
	Usage: npm run mkfs
*/
cli.command('mkfs').action(function () {
	cd(nodemcuToolPath)

	findPort(function (port) {
		require('child_process')
			.execSync(`node nodemcu-tool mkfs --port=${port}`, { stdio: 'inherit' })
	})
})

/*
	Command for uploading the source files.
	Usage: npm run upload
*/
cli.command('upload [prodFlag]').action(function (prodFlag) {
	const prod = !!prodFlag && !!~prodFlag.indexOf('prod')
	const compilePrefix = prod ? '--compile' : ''

	findPort(function (port) {
		var allFiles = ''
		var allHtml = ''

		ls('src/*.lua').forEach(function (filename) {
			allFiles += ` ${pathToSrc}/${filename}`
		})

		ls('html/*.htm').forEach(function (filename) {
			allHtml += ` ${pathToSrc}/${filename}`
		})

		cd(nodemcuToolPath)

		require('child_process')
			.execSync(`node nodemcu-tool upload ${allFiles} ${allHtml} ${compilePrefix} --port=${port} ${options}`, { stdio: 'inherit' })

		require('child_process')
			.execSync(`node nodemcu-tool upload ${pathToSrc}/init.lua --port=${port} ${options}`, { stdio: 'inherit' })

		require('child_process')
			.execSync(`node nodemcu-tool fsinfo --port=${port}`, { stdio: 'inherit' })
	})
})

/*
	Command running the script for uploading the config.json file on the hardware device.
	Usage: npm run config
*/
cli.command('config').action(function () {
	findPort(function (port) {
		cd(nodemcuToolPath)

		require('child_process')
			.execSync(`node nodemcu-tool upload ${pathToSrc}/src/config.json --port=${port} ${options}`, { stdio: 'inherit' })

		require('child_process')
			.execSync(`node nodemcu-tool fsinfo --port=${port}`, { stdio: 'inherit' })
	})
})

/*
	Command running the script for starting the lua terminal,
	to read data from the hardware device.
	Usage: npm start
*/
cli.command('start').action(function () {
	findPort(function (port) {
		cd(nodemcuToolPath)

		require('child_process')
			.execSync(`node nodemcu-tool reset --port=${port}`)

		require('child_process')
				.execSync(`node nodemcu-tool terminal --port=${port}`, { stdio: 'inherit' })
	})
})

/*
	Command for flashing the firmware,
	accepts folder path and flashing mode as an arguements
*/
cli.command('flash [folder] [mode]').action(function (folder, mode) {
	const folderPath = folder || 'firmware'
	const flashMode = mode || 'qio'

	console.log('Finding binaries to flash...')
	
	const binariesFound = ls(`${folderPath}/*.bin`)

	if (binariesFound.length) {
		console.log('Please type the index of the binary you want to flash')
	}

	binariesFound.forEach(function (file, index) {
		console.log(`${index}) ${file}`)
	})

	prompt.get([{
		name: 'binary-flash-index',
		required: true
	}], function (err, result) {
		const selectedIndex = parseInt(result['binary-flash-index'])

		if (binariesFound[selectedIndex]) {
			selectAddress((address) => {
				console.log('Flashing: ' + binariesFound[selectedIndex], ' on address: ', address, '...')

				findPort(function (port) {
					console.log('Erasing previous flash...')
					require('child_process')
						.execSync(`esptool.py --port ${port} erase_flash`, { stdio: 'inherit' })

					console.log('Flashing esp_init_data_default.bin at 0x3fc000')
					require('child_process')
						.execSync(`esptool.py --port ${port} write_flash -fm ${flashMode} 0x3fc000 firmware/esp_init_data_default.bin`, { stdio: 'inherit' })

					console.log(`Flashing ${binariesFound[selectedIndex]} at ${address}`)
					require('child_process')
						.execSync(`esptool.py --port ${port} write_flash -fm ${flashMode} ${address} ${binariesFound[selectedIndex]}`, { stdio: 'inherit' })
				})
			})
		} else {
			console.error('Invalid binary index selected.')
		}
	})
})

/*
	Handle execution of unknown commands.
*/
cli.command('*').action( function(c){
	console.error('Unknown command "' + c + '"')
	cli.outputHelp()
})

cli.parse(process.argv)
