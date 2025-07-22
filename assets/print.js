const escpos = require('escpos');
escpos.USB = require('escpos-usb');

// Setup printer
const device = new escpos.USB(); // auto-detect USB printer
const printer = new escpos.Printer(device);

const invoiceNo = "TRI1234";
const date = "2025-07-19 10:32 AM";
const from = "Location A";
const to = "Location B";

// Items (example data)
const items = [
    { name: "Abiman Takkali 25g", code: "abt125", qty: 10, unit: "Pack" },
    { name: "Abiman Takkali 25g", code: "abt125", qty: 5, unit: "Pack" },
    { name: "Abiman Takkali 25g", code: "abt125", qty: 2, unit: "Pack" },
];

device.open((err) => {
    if (err) {
        console.error('Error opening device:', err);
        return;
    }

    printer
        // Top padding
        .size(0, 0)
        .text('')

        // Open cash drawer
        .raw(Buffer.from([0x1B, 0x70, 0x00, 0x40, 0x40])) // Pin 2, adjust to 0x01 for pin 5 if needed

        // HEADER
        .align('CT')
        .style('B')
        .size(2, 1)
        .text('DPD Chemical')
        .style('B')
        .size(0, 0)
        .text('')
        .text('ITEM TRANSFER INVOICE')

        // INVOICE METADATA
        .align('LT')
        .style('NORMAL')
        .size(0, 0)
        .drawLine()

        .text(`Date       : ${date}`)
        .text(`Invoice No : ${invoiceNo}`)
        .text(`From       : ${from}`)
        .text(`To         : ${to}`)
        .drawLine()
        .drawLine()

        // TABLE HEADER
        .style('B')
        .size(0, 0)
        .text(`No  Item Name              Code     Qty  Unit`)
        .drawLine()
        .style('NORMAL');

    let total = 0;

    // ITEMS LOOP
    items.forEach((item, index) => {
        total += item.qty;
        printer
            .size(0, 0)
            .text(
                `${String(index + 1).padEnd(3)} ${item.name.padEnd(22)} ${item.code.padEnd(8)} ${String(item.qty).padEnd(4)} ${item.unit}`
            );
    });

    // TOTAL SECTION
    printer
        .drawLine()
        .style('B')
        .size(0, 0)
        .text(`TOTAL ITEMS    :   ${total}`)
        .drawLine()

        // NOTES
        .style('B')
        .size(0, 0)
        .text('')
        .text('NOTES :')

        .style('NORMAL')
        .size(0, 0)
        .text('Please verify items upon receipt.')
        .text('Report any missing/damaged items within 24hrs.')
        .text('')
        .text(`Sent By     : _________________________________`)
        .text(`Received By : _________________________________`)
        .text(`Date        : _________________________________`)
        .text('')
        .drawLine()

        // FOOTER
        .align('CT')
        .style('B')
        .size(0, 0)
        .text('Thank You !')
        .drawLine()

        // BARCODE
        // then invoiceNo as ASCII bytes, terminated with NUL
        .raw(Buffer.from([
            0x1D, 0x6B, 0x04,
            ...Buffer.from(invoiceNo, 'ascii'), 
            0x00
        ]))

        // HRI position (0x1D 0x48 0x02) → print below barcode
        .raw(Buffer.from([0x1D, 0x48, 0x02]))
        // Barcode height 80 dots
        .raw(Buffer.from([0x1D, 0x68, 80]))

        .size(0, 0)
        .text('')
        .text('Powered By AventaPOS')

        .size(2, 2)
        .text(' ')

        .cut()
        .close();
});