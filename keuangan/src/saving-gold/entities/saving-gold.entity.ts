import { Column, CreateDateColumn, Entity, ManyToOne, OneToMany, PrimaryColumn, UpdateDateColumn } from "typeorm"
import { SavingGoldOwner } from "./saving-gold-owner.entity";
import { User } from "src/model/user.entity";


@Entity()
export class SavingGold {
    @PrimaryColumn({ generated: "uuid" })
    id: string

    @Column({type:'decimal', precision:20, scale:2})
    price: number

    @Column({type:'float'})
    berat: number;

    @Column({type:'date'})
    date_trans: Date
    
    @Column({type:'enum', enum:['buy', 'sell'], default:'buy'})
    type_note:string;
    
    @ManyToOne(() => SavingGoldOwner, (own_gold)=> own_gold.savingGold, { nullable:false})
    owner_gold: SavingGoldOwner;

    @ManyToOne(() => User, (user)=> user.savingGoldOwner)
    user: User;
    
    @CreateDateColumn()
    createdon: Date;
    
    @UpdateDateColumn()
    updatedon: Date;
}