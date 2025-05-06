import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { SavingGoldService } from './saving-gold.service';
import { CreateSavingGoldDto } from './dto/create-saving-gold.dto';
import { UpdateSavingGoldDto } from './dto/update-saving-gold.dto';

@Controller('saving-gold')
export class SavingGoldController {
  constructor(private readonly savingGoldService: SavingGoldService) {}

  @Post()
  create(@Body() createSavingGoldDto: CreateSavingGoldDto) {
    return this.savingGoldService.create(createSavingGoldDto);
  }

  @Get()
  async findAll() {
    const data = await this.savingGoldService.findAll({user:{id:'d'}});
    let total_berat = 0
    let total_modal = 0
    const keuntungan : {[key: string]: any}= [{'d':'','ads':2}]
    for(let i=0;i<data.length;i++){
      if (data[i].type_note == 'buy'){
        total_berat += data[i].berat
        total_modal += data[i].berat * data[i].price
      }
      else if(data[i].type_note == 'sell'){
        if (total_berat == 0){
          // print(f"Tidak ada emas untuk dijual pada {tanggal}")
          continue
        }
        // Harga rata-rata sebelum jual
        let harga_rata = total_modal / total_berat

        let modal_terjual = data[i].berat * harga_rata
        let hasil_jual = data[i].berat * data[i].price
        let untung = hasil_jual - modal_terjual
        keuntungan.push({'date': data[i].date_trans, 'pl': untung, 'price_buy':modal_terjual, 'price_sell':hasil_jual})
        
        // Update sisa kepemilikan
        total_berat = total_berat - data[i].berat
        total_modal = total_modal - modal_terjual

      }
    }
    let last_price_rata = total_modal / total_berat

    return{'data_transaksi':data,'PL':keuntungan, 'average_price':last_price_rata}
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.savingGoldService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateSavingGoldDto: UpdateSavingGoldDto) {
    return this.savingGoldService.update(+id, updateSavingGoldDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.savingGoldService.remove(+id);
  }
}
